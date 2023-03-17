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
}

public class MetadataCaptureOutput: NSObject, CaptureOutput, AVCaptureMetadataOutputObjectsDelegate {

    // MARK: - MetadataCaptureOutput.ObjectType
    public typealias ObjectType = AVMetadataObject.ObjectType

    // MARK: - Properties
    public let captureOutput: AVCaptureMetadataOutput

    public lazy var outputStream: AsyncStream<AVMetadataObject> = AsyncStream { self.outputContinuation = $0 }
    private var outputContinuation: AsyncStream<AVMetadataObject>.Continuation?

    // MARK: - Initializer
    public override init() {
        self.captureOutput = .init()
        super.init()

        captureOutput.setMetadataObjectsDelegate(self, queue: .main)
    }

    // MARK: - Interface
    public var availableMetadataObjectTypes: [ObjectType] { return captureOutput.availableMetadataObjectTypes }

    public func setMetadataObjectTypes(_ objectTypes: [ObjectType]) {
        captureOutput.metadataObjectTypes = objectTypes
    }

    // MARK: - CaptureOutput
    public var rawOutput: AVCaptureOutput { return captureOutput }

    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        for metadataObject in metadataObjects {
            outputContinuation?.yield(metadataObject)
        }
    }
}
