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
    public var rectOfInterest: CGRect {
        didSet { metadataOutput.rectOfInterest = rectOfInterest }
    }

    public var outputStream: AsyncStream<AVMetadataObject> { return metadataOutput.outputStream }

    // MARK: - Initializer
    public init(metadataTypes: [MetadataCaptureOutput.ObjectType],
                captureSessionConfiguration: CaptureSession.Configuration = .init(preset: .high),
                captureInput: CaptureInput) {
        self.authorizationService = .init(requestedMediaType: .video)
        self.captureSession = CaptureSession(configuration: captureSessionConfiguration)
        self.previewLayer = AVCaptureVideoPreviewLayer()
        self.metadataOutput = MetadataCaptureOutput()
        self.rectOfInterest = metadataOutput.rectOfInterest

        Task {
            await captureSession.addInput(captureInput)
            await captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectTypes(metadataTypes)

            await captureSession.startRunning()

            // TODO: This needs some further investigation as to how and when it should be set up
            metadataOutput.rectOfInterest = rectOfInterest
        }
    }

    // MARK: - Preset
    public static func defaultVideo(capturing metadataTypes: [MetadataCaptureOutput.ObjectType],
                                    captureSessionConfiguration: CaptureSession.Configuration = .init(preset: .high)) throws -> MetadataCaptureSession {
        guard let captureInput = try CameraCaptureInput.default(forCapturing: .video) else {
            throw Error.noDeviceAvailable
        }

        return MetadataCaptureSession(metadataTypes: metadataTypes, captureSessionConfiguration: captureSessionConfiguration, captureInput: captureInput)
    }

    // MARK: - Interface
    public var capturePreview: CapturePreview { return .init(session: captureSession, previewLayer: previewLayer) }

    public func transformedMetadataObjectPlacement(for object: AVMetadataObject) -> AVCaptureVideoPreviewLayer.Placement? {
        return previewLayer.transformedMetadataObjectPlacement(for: object)
    }

    public func set(rectOfInterest rect: CGRect) {
        let convertedRect = previewLayer.metadataOutputRectConverted(fromLayerRect: rect)
        rectOfInterest = convertedRect
    }
}
