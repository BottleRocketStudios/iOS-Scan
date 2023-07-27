//
//  CaptureDevice.swift
//  
//
//  Created by Will McGinty on 3/28/23.
//

import AVFoundation

public struct CaptureDevice: Identifiable {

    // MARK: - CaptureDevice.Kind
    public typealias Kind = AVCaptureDevice.DeviceType

    // MARK: - CaptureDevice.Position
    public typealias Position = AVCaptureDevice.Position

    // MARK: - Properties
    public let device: AVCaptureDevice

    // MARK: - Initializer
    public init(device: AVCaptureDevice) {
        self.device = device
    }

    // MARK: - Interface
    public var id: String { return device.uniqueID }
    public var modelID: String { return device.modelID }
    public var localizedName: String { return device.localizedName }
    public var manufacturer: String { return device.manufacturer }
    public var kind: Kind { return device.deviceType }
    public var position: Position { return device.position }
}

// MARK: - Device Configuration
public extension CaptureDevice {

    func beginConfiguration() throws {
        try device.lockForConfiguration()
    }

    func performConfiguration(_ configuration: (AVCaptureDevice) -> Void) throws {
        try beginConfiguration()
        configuration(device)
        commitConfiguration()
    }

    func commitConfiguration() {
        device.unlockForConfiguration()
    }
}

// MARK: - CaptureDevice + Preset
public extension CaptureDevice {

    static func `default`(forCapturing mediaType: MediaType) -> CaptureDevice? {
        return AVCaptureDevice.default(for: mediaType).flatMap(CaptureDevice.init)
    }

    static func `default`(of type: Kind, forCapturing mediaType: MediaType?, position: Position) -> CaptureDevice? {
        return AVCaptureDevice.default(type, for: mediaType, position: position).flatMap(CaptureDevice.init)
    }

    static func devices(ofKinds kinds: [Kind], forCapturing mediaType: MediaType?, position: Position) -> [CaptureDevice] {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: kinds, mediaType: mediaType, position: position)
        return discoverySession.devices.compactMap(CaptureDevice.init)
    }
}
