//
//  CaptureSession.swift
//  
//
//  Created by Will McGinty on 3/17/23.
//

import AVFoundation

// MARK: - Typeliases
public typealias VideoPreviewLayer = AVCaptureVideoPreviewLayer
public typealias CaptureConnection = AVCaptureConnection
public typealias MachineReadableMetadataObject = AVMetadataMachineReadableCodeObject

public actor CaptureSession {

    // MARK: - CaptureSession.Configuration
    public struct Configuration {

        // MARK: - CaptureSession.Configuration.Preset
        public typealias Preset = AVCaptureSession.Preset

        // MARK: - Properties
        let preset: Preset?

        // MARK: - Initializer
        public init(preset: Preset? = nil) {
            self.preset = preset
        }
    }

    // MARK: - Properties
    public let captureSession: AVCaptureSession

    // MARK: - Initializer
    public init(configuration: Configuration) {
        captureSession = .init()

        Task {
            await apply(configuration: configuration)
        }
    }

    // MARK: - Interface
    public var isRunning: Bool { return captureSession.isRunning }
    public var isInterrupted: Bool { return captureSession.isInterrupted }

    @available(iOS 16.0, *)
    public var hardwareCost: Float { return captureSession.hardwareCost }

    @available(iOS 16.0, *)
    public var isMultitaskingCameraAccessSupported: Bool {
        return captureSession.isMultitaskingCameraAccessSupported
    }

    @available(iOS 16.0, *)
    public var isMultitaskingCameraAccessEnabled: Bool {
        get { return captureSession.isMultitaskingCameraAccessEnabled }
        set { captureSession.isMultitaskingCameraAccessEnabled = newValue }
    }

    public var usesApplicationAudioSession: Bool {
        get { return captureSession.usesApplicationAudioSession }
        set { captureSession.usesApplicationAudioSession = newValue }
    }

    public var automaticallyConfiguresApplicationAudioSession: Bool {
        get { return captureSession.automaticallyConfiguresApplicationAudioSession }
        set { captureSession.automaticallyConfiguresApplicationAudioSession = newValue }
    }

    public var automaticallyConfiguresCaptureDeviceForWideColor: Bool {
        get { return captureSession.automaticallyConfiguresCaptureDeviceForWideColor }
        set { captureSession.automaticallyConfiguresCaptureDeviceForWideColor = newValue }
    }

    public func beginConfiguration() {
        captureSession.beginConfiguration()
    }

    public func commitConfiguration() {
        captureSession.commitConfiguration()
    }

    public func startRunning() {
        captureSession.startRunning()
    }

    public func stopRunning() {
        captureSession.stopRunning()
    }
}

// MARK: - Inputs and Outputs
public extension CaptureSession {

    func canAddInput(_ input: some CaptureInput) -> Bool {
        return captureSession.canAddInput(input.rawInput)
    }

    func addInput(_ input: some CaptureInput) {
        guard canAddInput(input) else { return }
        performConfiguration {
            $0.addInput(input.rawInput)
        }
    }

    func removeInput(_ input: some CaptureInput) {
        performConfiguration {
            $0.removeInput(input.rawInput)
        }
    }

    func canAddOutput(_ output: some CaptureOutput) -> Bool {
        return captureSession.canAddOutput(output.rawOutput)
    }

    func addOutput(_ output: some CaptureOutput) {
        guard canAddOutput(output) else { return }
        performConfiguration {
            $0.addOutput(output.rawOutput)
        }
    }

    func removeOutput(_ output: some CaptureOutput) {
        performConfiguration {
            $0.removeOutput(output.rawOutput)
        }
    }
}

// MARK: - Helper
private extension CaptureSession {

    func apply(configuration: Configuration) {
        guard let sessionPreset = configuration.preset, captureSession.canSetSessionPreset(sessionPreset) else { return }
        captureSession.sessionPreset = sessionPreset
    }

    func performConfiguration(_ configuration: (AVCaptureSession) -> Void) {
        beginConfiguration()
        configuration(captureSession)
        commitConfiguration()
    }
}
