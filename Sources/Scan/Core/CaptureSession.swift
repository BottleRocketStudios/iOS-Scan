//
//  CaptureSession.swift
//  
//
//  Created by Will McGinty on 3/17/23.
//

import AVFoundation

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

    public var usesApplicationAudioSession: Bool { return captureSession.usesApplicationAudioSession }
    public var automaticallyConfiguresApplicationAudioSession: Bool { return captureSession.automaticallyConfiguresApplicationAudioSession }
    public var automaticallyConfiguresCaptureDeviceForWideColor: Bool { return captureSession.automaticallyConfiguresCaptureDeviceForWideColor }

    public func startRunning() {
        captureSession.startRunning()
    }

    public func stopRunning() {
        captureSession.stopRunning()
    }
}

// MARK: - Inputs
public extension CaptureSession {

    func addInput(_ input: some CaptureInput) {
        guard captureSession.canAddInput(input.rawInput) else { return }
        performConfigurationAction {
            $0.addInput(input.rawInput)
        }
    }

    func addOutput(_ output: some CaptureOutput) {
        guard captureSession.canAddOutput(output.rawOutput) else { return }
        performConfigurationAction {
            $0.addOutput(output.rawOutput)
        }
    }
}

// MARK: - Helper
private extension CaptureSession {

    func apply(configuration: Configuration) {
        guard let sessionPreset = configuration.preset, captureSession.canSetSessionPreset(sessionPreset) else { return }
        captureSession.sessionPreset = sessionPreset
    }

    func performConfigurationAction(_ configuration: (AVCaptureSession) -> Void) {
        captureSession.beginConfiguration()
        configuration(captureSession)
        captureSession.commitConfiguration()
    }
}
