//
//  VideoCaptureSession.swift
//  
//
//  Created by Will McGinty on 3/21/23.
//

import Foundation
import AVFoundation
import Vision

public class VideoCaptureSession: ObservableObject {

    enum Error: Swift.Error {
        case noDeviceAvailable
    }

    // MARK: - Properties
    public let authorizationService: CaptureAuthorizationService
    public let captureSession: CaptureSession
    public let videoOutput: VideoCaptureOutput
    public let previewLayer: AVCaptureVideoPreviewLayer

    public var outputStream: AsyncStream<CVPixelBuffer> { return videoOutput.outputStream }

    // MARK: - Initializer
    public init(captureSessionConfiguration: CaptureSession.Configuration = .init(preset: .high),
                captureInput: CaptureInput) {
        self.authorizationService = .init(requestedMediaType: .video)
        self.captureSession = CaptureSession(configuration: captureSessionConfiguration)
        self.previewLayer = AVCaptureVideoPreviewLayer(cameraSession: captureSession, videoGravity: .resizeAspect)
        self.videoOutput = VideoCaptureOutput()

        Task {
            await captureSession.addInput(captureInput)
            await captureSession.addOutput(videoOutput)

            if let videoConnection = videoOutput.connection(with: .video), videoConnection.isVideoOrientationSupported {
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
}
