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
    private let captureDeviceInput: AVCaptureInput

    // MARK: - Initializer
    public init(captureDeviceInput: AVCaptureInput) {
        self.captureDeviceInput = captureDeviceInput
    }

    // MARK: - CaptureInput
    public var rawInput: AVCaptureInput { return captureDeviceInput }
}

// MARK: - Preset
public extension CameraCaptureInput {

    typealias DeviceType = AVCaptureDevice.DeviceType
    typealias Position = AVCaptureDevice.Position

    static func `default`(forCapturing mediaType: MediaType) throws -> CameraCaptureInput? {
        return try AVCaptureDevice.default(for: mediaType).flatMap {
            let captureInput = try AVCaptureDeviceInput(device: $0)
            return CameraCaptureInput(captureDeviceInput: captureInput)
        }
    }

    static func `default`(of type: DeviceType, forCapturing mediaType: MediaType?, position: Position) throws -> CameraCaptureInput? {
        return try AVCaptureDevice.default(type, for: mediaType, position: position).flatMap {
            let captureInput = try AVCaptureDeviceInput(device: $0)
            return CameraCaptureInput(captureDeviceInput: captureInput)
        }
    }

    static func inputOptions(forDeviceTypes types: [DeviceType], forCapturing mediaType: MediaType?, position: Position) throws -> [CameraCaptureInput] {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: types, mediaType: mediaType, position: position)
        return try discoverySession.devices.compactMap {
            let captureInput = try AVCaptureDeviceInput(device: $0)
            return CameraCaptureInput(captureDeviceInput: captureInput)
        }
    }
}
