//
//  PhotoCaptureSession.swift
//  Scan
//
//  Created by Will McGinty on 1/2/25.
//

import AVFoundation
import UIKit

public class PhotoCaptureSession {

    // MARK: - Nested Types
    public enum Error: Swift.Error {
        case noDeviceAvailable
    }

    // MARK: - Properties
    public let authorizationService: CaptureAuthorizationService
    public let captureSession: CaptureSession
    public let photoOutput: PhotoCaptureOutput
    public let previewLayer: VideoPreviewLayer

    public var outputStream: AsyncStream<Data> { return photoOutput.outputStream }

    // MARK: - Initializer
    public init(captureSessionConfiguration: CaptureSession.Configuration = .init(preset: .photo),
                captureInput: CaptureInput,
                previewVideoGravity: AVLayerVideoGravity = .resizeAspect) throws {
        self.authorizationService = .init(requestedMediaType: .video)
        self.captureSession = CaptureSession(configuration: captureSessionConfiguration)
        self.previewLayer = VideoPreviewLayer(cameraSession: captureSession, videoGravity: previewVideoGravity)
        self.photoOutput = PhotoCaptureOutput()

        Task {
            await captureSession.addInput(captureInput)
            await captureSession.addOutput(photoOutput)

            await captureSession.startRunning()
        }
    }

    // MARK: - Preset
    public static func defaultPhoto(captureSessionConfiguration: CaptureSession.Configuration = .init(preset: .photo),
                                    previewVideoGravity: AVLayerVideoGravity = .resizeAspect) throws -> PhotoCaptureSession {
        guard let captureInput = try CameraCaptureInput.default(forCapturing: .video) else {
            throw Error.noDeviceAvailable
        }

        return try PhotoCaptureSession(captureSessionConfiguration: captureSessionConfiguration, captureInput: captureInput, previewVideoGravity: previewVideoGravity)
    }

    public static func defaultFrontFacingPhoto(captureSessionConfiguration: CaptureSession.Configuration = .init(preset: .photo),
                                    previewVideoGravity: AVLayerVideoGravity = .resizeAspect) throws -> PhotoCaptureSession {
        guard let captureInput = try CameraCaptureInput.default(of: .builtInWideAngleCamera, forCapturing: .video, position: .front) else {
            throw Error.noDeviceAvailable
        }

        return try PhotoCaptureSession(captureSessionConfiguration: captureSessionConfiguration, captureInput: captureInput, previewVideoGravity: previewVideoGravity)
    }

    // MARK: - Interface
    public var capturePreview: CapturePreview { return .init(session: captureSession, previewLayer: previewLayer) }

    /// Captures a photo asynchronously and returns the image data via a completion handler.
    public func capturePhoto(completion: @escaping (Result<Data, Swift.Error>) -> Void) {
        photoOutput.capturePhoto()
        Task {
            for await photoData in photoOutput.outputStream {
                completion(.success(photoData))
                break
            }
        }
    }
}
