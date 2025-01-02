//
//  CaptureOutput.swift
//  
//
//  Created by Will McGinty on 3/17/23.
//

import AVFoundation

public protocol CaptureOutput {

    // TODO: Can this be accomplished without exposing `AVCaptureOutput` outside of the package?
    var rawOutput: AVCaptureOutput { get }

    var connections: [CaptureConnection] { get }
    func connection(with mediaType: MediaType) -> CaptureConnection?

    func transformedMetadataObject(for metadataObject: MetadataObject, connection: CaptureConnection) -> MetadataObject?
    func metadataOutputRectConverted(fromOutputRect rect: CGRect) -> CGRect
    func outputRectConverted(fromMetadataOutputRect rect: CGRect) -> CGRect
}

public extension CaptureOutput {

    var connections: [CaptureConnection] { return rawOutput.connections }

    func connection(with mediaType: MediaType) -> CaptureConnection? {
        return rawOutput.connection(with: mediaType)
    }

    func transformedMetadataObject(for metadataObject: MetadataObject, connection: CaptureConnection) -> MetadataObject? {
        return rawOutput.transformedMetadataObject(for: metadataObject, connection: connection)
    }

    func metadataOutputRectConverted(fromOutputRect rect: CGRect) -> CGRect {
        return rawOutput.metadataOutputRectConverted(fromOutputRect: rect)
    }

    func outputRectConverted(fromMetadataOutputRect rect: CGRect) -> CGRect {
        return rawOutput.outputRectConverted(fromMetadataOutputRect: rect)
    }
}

public class MetadataCaptureOutput: NSObject, CaptureOutput, AVCaptureMetadataOutputObjectsDelegate {

    public enum OutputTypes {
        case allAvailable
        case specific(types: [MetadataObject.ObjectType])

        // MARK: - Initializer
        public init(_ objectTypes: [MetadataObject.ObjectType]) {
            self = .specific(types: objectTypes)
        }
    }

    // MARK: - Properties
    public let captureOutput: AVCaptureMetadataOutput

    public lazy var outputStream: AsyncStream<MetadataObject> = AsyncStream { self.outputContinuation = $0 }
    private var outputContinuation: AsyncStream<MetadataObject>.Continuation?

    // MARK: - Initializer
    public override init() {
        captureOutput = .init()
        super.init()

        captureOutput.setMetadataObjectsDelegate(self, queue: .main)
    }

    // MARK: - Interface
    public var availableMetadataObjectTypes: [MetadataObject.ObjectType] { return captureOutput.availableMetadataObjectTypes }

    public var rectOfInterest: CGRect {
        get { return captureOutput.rectOfInterest }
        set { captureOutput.rectOfInterest = newValue }
    }

    public func setMetadataObjectTypes(_ objectTypes: OutputTypes) {
        switch objectTypes {
        case .specific(types: let types): setMetadataObjectTypes(types)
        case .allAvailable:
            let availableTypes = availableMetadataObjectTypes
            setMetadataObjectTypes(availableTypes)
        }
    }

    public func setMetadataObjectTypes(_ objectTypes: [MetadataObject.ObjectType]) {
        captureOutput.metadataObjectTypes = objectTypes
    }

    // MARK: - CaptureOutput
    public var rawOutput: AVCaptureOutput { return captureOutput }


    // MARK: - AVCaptureMetadataOutputObjectsDelegate
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [MetadataObject], from connection: CaptureConnection) {
        for metadataObject in metadataObjects {
            outputContinuation?.yield(metadataObject)
        }
    }
}

public class VideoCaptureOutput: NSObject, CaptureOutput, AVCaptureVideoDataOutputSampleBufferDelegate {

    // MARK: - Properties
    public let captureOutput: AVCaptureVideoDataOutput

    public lazy var outputStream: AsyncStream<CVPixelBuffer> = AsyncStream { self.outputContinuation = $0 }
    private var outputContinuation: AsyncStream<CVPixelBuffer>.Continuation?

    // MARK: - Initializer
    public override init() {
        captureOutput = .init()
        captureOutput.videoSettings = [:]
        super.init()

        captureOutput.setSampleBufferDelegate(self, queue: .main)
    }

    // MARK: - Interface

    // Output Configuration
    public var videoSettings: [String: Any] {
        get { return captureOutput.videoSettings }
        set { captureOutput.videoSettings = newValue }
    }

    public var alwaysDiscardsLateVideoFrames: Bool {
        get { return captureOutput.alwaysDiscardsLateVideoFrames }
        set { captureOutput.alwaysDiscardsLateVideoFrames = newValue }
    }

    public var automaticallyConfiguresOutputBufferDimensions: Bool {
        get { return captureOutput.automaticallyConfiguresOutputBufferDimensions }
        set { captureOutput.automaticallyConfiguresOutputBufferDimensions = newValue }
    }

    public var deliversPreviewSizedOutputBuffers: Bool {
        get { return captureOutput.deliversPreviewSizedOutputBuffers }
        set { captureOutput.deliversPreviewSizedOutputBuffers = newValue }
    }

    public func recommendedVideoSettings(forVideoCodecType codecType: AVVideoCodecType, assetWriterOutputFileType fileType: AVFileType) -> [String: Any]? {
        return captureOutput.recommendedVideoSettings(forVideoCodecType: codecType, assetWriterOutputFileType: fileType)
    }

    public func recommendedVideoSettingsForAssetWriter(writingTo fileType: AVFileType) -> [String: Any]? {
        return captureOutput.recommendedVideoSettingsForAssetWriter(writingTo: fileType)
    }

    // Supported Video Types
    public var availableVideoCodecTypes: [AVVideoCodecType] {
        return captureOutput.availableVideoCodecTypes
    }

    public var availableVideoPixelFormatTypes: [OSType] {
        return captureOutput.availableVideoPixelFormatTypes
    }

    func availableVideoCodecTypesForAssetWriter(writingTo fileType: AVFileType) -> [AVVideoCodecType] {
        return captureOutput.availableVideoCodecTypesForAssetWriter(writingTo: fileType)
    }

    // MARK: - CaptureOutput
    public var rawOutput: AVCaptureOutput { return captureOutput }

    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: CaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        outputContinuation?.yield(pixelBuffer)
    }
}

public class PhotoCaptureOutput: NSObject, CaptureOutput, AVCapturePhotoCaptureDelegate {

    // MARK: - Properties
    public let captureOutput: AVCapturePhotoOutput

    public lazy var outputStream: AsyncStream<Data> = AsyncStream { self.outputContinuation = $0 }
    private var outputContinuation: AsyncStream<Data>.Continuation?

    private var photoSettings: AVCapturePhotoSettings?

    // MARK: - Initializer
    public override init() {
        self.captureOutput = AVCapturePhotoOutput()
        super.init()
    }

    // MARK: - Interface
    public func configurePhotoSettings(format: [String: Any]? = nil, isHighResolution: Bool = false) {
        let settings = AVCapturePhotoSettings(format: format)
        self.photoSettings = settings
    }

    public func capturePhoto() {
        let settings = photoSettings ?? AVCapturePhotoSettings()
        captureOutput.capturePhoto(with: settings, delegate: self)
    }

    public var isLivePhotoCaptureSupported: Bool {
        return captureOutput.isLivePhotoCaptureSupported
    }

    public var isLivePhotoCaptureEnabled: Bool {
        get { return captureOutput.isLivePhotoCaptureEnabled }
        set { captureOutput.isLivePhotoCaptureEnabled = newValue }
    }

    public var flashMode: AVCaptureDevice.FlashMode {
        get { return photoSettings?.flashMode ?? .off }
        set {
            let settings = photoSettings ?? AVCapturePhotoSettings()
            settings.flashMode = newValue
            self.photoSettings = settings
        }
    }

    // MARK: - CaptureOutput
    public var rawOutput: AVCaptureOutput { return captureOutput }

    // MARK: - AVCapturePhotoCaptureDelegate
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Swift.Error?) {
        guard let data = photo.fileDataRepresentation() else {
            debugPrint("Error capturing photo.", String(describing: error?.localizedDescription))
            outputContinuation?.finish(); return
        }

        outputContinuation?.yield(data)
    }
}
