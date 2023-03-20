//
//  MetadataCaptureSession.swift
//  
//
//  Created by Will McGinty on 3/20/23.
//

import AVFoundation

public class MetadataCaptureSession: ObservableObject {

    enum Error: Swift.Error {
        case noDeviceAvailable
    }

    // MARK: - Properties
    public let authorizationService: CaptureAuthorizationService
    public let captureSession: CaptureSession
    public let metadataOutput: MetadataCaptureOutput
    public let previewLayer: AVCaptureVideoPreviewLayer

    public var outputStream: AsyncStream<AVMetadataObject> { return metadataOutput.outputStream }

    // MARK: - Initializer
    public init(metadataTypes: [MetadataCaptureOutput.ObjectType]) throws {
        self.authorizationService = .init(requestedMediaType: .video)
        self.captureSession = CaptureSession(configuration: .init(preset: .high))
        self.previewLayer = .init()
        self.metadataOutput = MetadataCaptureOutput()

        guard let cameraInput = try CameraCaptureInput.default(forCapturing: .video) else {
            throw Error.noDeviceAvailable
        }

        Task {
            await captureSession.addInput(cameraInput)
            await captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectTypes(metadataTypes)

            await captureSession.startRunning()
        }
    }

    // MARK: - Interface
    public func transformedMetadataObjectPlacement(for object: AVMetadataObject) -> AVCaptureVideoPreviewLayer.Placement? {
        return previewLayer.transformedMetadataObjectPlacement(for: object)
    }
}
