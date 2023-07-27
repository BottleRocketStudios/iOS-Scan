//
//  VideoCaptureSession.swift
//  
//
//  Created by Will McGinty on 3/21/23.
//

import Foundation
import AVFoundation
import Vision

/*
 https://machinethink.net/blog/bounding-boxes/
 */

public class VideoCaptureSession: ObservableObject {

    enum Error: Swift.Error {
        case noDeviceAvailable
    }

    // MARK: - Properties
    public let authorizationService: CaptureAuthorizationService
    public let captureSession: CaptureSession
    public let videoOutput: VideoCaptureOutput
    public let previewLayer: VideoPreviewLayer

    public var outputStream: AsyncStream<CVPixelBuffer> { return videoOutput.outputStream }

    // MARK: - Initializer
    public init(captureSessionConfiguration: CaptureSession.Configuration = .init(preset: .high),
                captureInput: CaptureInput) {
        self.authorizationService = .init(requestedMediaType: .video)
        self.captureSession = CaptureSession(configuration: captureSessionConfiguration)
        self.previewLayer = VideoPreviewLayer(cameraSession: captureSession)
        self.videoOutput = VideoCaptureOutput()

        Task {
            await captureSession.addInput(captureInput)
            await captureSession.addOutput(videoOutput)

            if let videoConnection = videoOutput.connection(with: .video), videoConnection.isVideoOrientationSupported {
                debugPrint("Setting videoOrientation to .portrait")
                videoConnection.videoOrientation = .portrait
            }

            await captureSession.startRunning()
        }
    }

    // MARK: - Preset
    public static func defaultVideo(captureSessionConfiguration: CaptureSession.Configuration = .init(preset: .high)) throws -> VideoCaptureSession {
        guard let captureInput = try CameraCaptureInput.default(forCapturing: .video) else {
            throw Error.noDeviceAvailable
        }

        return VideoCaptureSession(captureSessionConfiguration: captureSessionConfiguration, captureInput: captureInput)
    }

    // MARK: - Interface
    public var capturePreview: CapturePreview { return .init(session: captureSession, previewLayer: previewLayer) }

    public func transformedViewRect(forNormalizedBoundingBox boundingBox: CGRect) -> CGRect {
        return VNImageRectForNormalizedRect(boundingBox, Int(previewLayer.bounds.width), Int(previewLayer.bounds.height))
    }

    public func transformedPlacement(forNormalizedBoundingBox boundingBox: CGRect) -> Placement {
        let flippedBox = CGRect(x: boundingBox.origin.x, y: 1 - boundingBox.origin.y, width: boundingBox.height, height: boundingBox.width)
        let converted = CGRect(x: flippedBox.origin.x * previewLayer.frame.size.width, y: flippedBox.origin.y * previewLayer.frame.size.height,
                               width: boundingBox.width * previewLayer.frame.size.width, height: boundingBox.height * previewLayer.frame.size.height)
//        let viewRect = transformedViewRect(forNormalizedBoundingBox: flippedBox)
//        let converted = previewLayer.layerRectConverted(fromMetadataOutputRect: boundingBox)
        return .init(converted)
    }
}
