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
    public let previewLayer: VideoPreviewLayer
    public var rectOfInterest: CGRect {
        didSet { metadataOutput.rectOfInterest = rectOfInterest }
    }

    public var outputStream: AsyncStream<MetadataObject> { return metadataOutput.outputStream }

    // MARK: - Initializer
    public init(outputTypes: MetadataCaptureOutput.OutputTypes,
                captureSessionConfiguration: CaptureSession.Configuration = .init(preset: .high),
                captureInput: CaptureInput) {
        self.authorizationService = .init(requestedMediaType: .video)
        self.captureSession = CaptureSession(configuration: captureSessionConfiguration)
        self.previewLayer = VideoPreviewLayer(cameraSession: captureSession)
        self.metadataOutput = MetadataCaptureOutput()
        self.rectOfInterest = metadataOutput.rectOfInterest

        Task {
            await captureSession.addInput(captureInput)
            await captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectTypes(outputTypes)

            await captureSession.startRunning()

            metadataOutput.rectOfInterest = rectOfInterest
        }
    }

    // MARK: - Preset
    public static func defaultVideo(capturing outputTypes: MetadataCaptureOutput.OutputTypes,
                                    captureSessionConfiguration: CaptureSession.Configuration = .init(preset: .high)) throws -> MetadataCaptureSession {
        guard let captureInput = try CameraCaptureInput.default(forCapturing: .video) else {
            throw Error.noDeviceAvailable
        }

        return MetadataCaptureSession(outputTypes: outputTypes, captureSessionConfiguration: captureSessionConfiguration, captureInput: captureInput)
    }

    // MARK: - Interface
    public var capturePreview: CapturePreview { return .init(session: captureSession, previewLayer: previewLayer) }

    public func setViewRectOfInterest(_ rect: CGRect) {
        rectOfInterest = previewLayer.metadataOutputRectConverted(fromLayerRect: rect)
    }

    public func transformedMetadataObjectPlacement(for object: AVMetadataObject) -> Placement? {
        return previewLayer.transformedMetadataObjectPlacement(for: object)
    }

    public func layerPlacement(forBoundingBox boundingBox: CGRect) -> Placement {
        return previewLayer.layerPlacement(forBoundingBox: boundingBox)
    }
}
