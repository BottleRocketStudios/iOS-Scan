//
//  CaptureInput.swift
//  
//
//  Created by Will McGinty on 3/17/23.
//

import AVFoundation

public protocol CaptureInput {

    // TODO: Can this be accomplished without exposing `AVCaptureInput` outside of the package?
    var rawInput: AVCaptureInput { get }
}

// MARK: - CameraCaptureInput
public class CameraCaptureInput: CaptureInput {

    // MARK: - Properties
    public let captureInput: AVCaptureDeviceInput

    // MARK: - Initializers
    public init(captureInput: AVCaptureDeviceInput) {
        self.captureInput = captureInput
    }

    public convenience init(captureDevice: CaptureDevice) throws {
        try self.init(captureInput: .init(device: captureDevice.device))
    }

    // MARK: - CaptureInput
    public var rawInput: AVCaptureInput { return captureInput }
}

// MARK: - Preset
public extension CameraCaptureInput {

    static func `default`(forCapturing mediaType: MediaType) throws -> CameraCaptureInput? {
        return try CaptureDevice.default(forCapturing: mediaType).flatMap(CameraCaptureInput.init)
    }

    static func `default`(of kind: CaptureDevice.Kind, forCapturing mediaType: MediaType?, position: CaptureDevice.Position) throws -> CameraCaptureInput? {
        return try CaptureDevice.default(of: kind, forCapturing: mediaType, position: position).flatMap(CameraCaptureInput.init)
    }

    static func inputDevices(ofKinds kinds: [CaptureDevice.Kind], forCapturing mediaType: MediaType?, position: CaptureDevice.Position) throws -> [CameraCaptureInput] {
        return try CaptureDevice.devices(ofKinds: kinds, forCapturing: mediaType, position: position).compactMap(CameraCaptureInput.init)
    }
}
