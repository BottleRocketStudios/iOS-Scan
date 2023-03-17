//
//  ContentView.swift
//  Example
//
//  Created by Will McGinty on 3/17/23.
//

import AVFoundation
import SwiftUI
import Scan

struct ContentView: View {

    // MARK: - ContentView.ViewModel
    @MainActor
    class ViewModel: ObservableObject {

        // MARK: - Properties
        let authorizationService: CaptureAuthorizationService
        let captureSession: CaptureSession
        let previewLayer: AVCaptureVideoPreviewLayer
        let metadataOutput: MetadataCaptureOutput

        @Published var recognizedObject: AVMetadataMachineReadableCodeObject?

        // MARK: - Initializer
        init(capturingMediaType: MediaType) {
            self.authorizationService = .init(requestedMediaType: capturingMediaType)
            self.captureSession = CaptureSession(configuration: .init(preset: .high))
            self.previewLayer = .init()
            self.metadataOutput = MetadataCaptureOutput()

            Task {
                guard let cameraInput = try? CameraCaptureInput.default(forCapturing: capturingMediaType) else { return }

                await captureSession.addInput(cameraInput)
                await captureSession.addOutput(metadataOutput)
                metadataOutput.setMetadataObjectTypes([.qr])

                await captureSession.startRunning()

                for await object in metadataOutput.outputStream {
                    guard let readable = object as? AVMetadataMachineReadableCodeObject else { continue }
                    recognizedObject = readable
                }
            }
        }
    }

    // MARK: - Properties
    @StateObject var viewModel = ViewModel(capturingMediaType: .video)

    // MARK: - Interface
    private func recognizedObjectSize(in rect: CGRect) -> CGSize? {
        guard let recognized = viewModel.recognizedObject,
              let transformed = viewModel.previewLayer.transformedMetadataObject(for: recognized) else { return nil }

        return transformed.bounds.size
    }

    private func recognizedObjectPosition(in rect: CGRect) -> CGPoint? {
        guard let recognized = viewModel.recognizedObject,
              let transformed = viewModel.previewLayer.transformedMetadataObject(for: recognized) else { return nil }

        return CGPoint(x: transformed.bounds.midX, y: transformed.bounds.midY)
    }

    // MARK: - View
    var body: some View {
        CapturePreview(session: viewModel.captureSession, previewLayer: viewModel.previewLayer)
           .task {
               _ = await viewModel.authorizationService.requestAuthorization()
           }
           .overlay(alignment: .bottom) {
               Text(viewModel.recognizedObject?.stringValue ?? "--")
           }
           .overlay {
               GeometryReader { proxy in
                   if let size = recognizedObjectSize(in: proxy.frame(in: .local)), let position = recognizedObjectPosition(in: proxy.frame(in: .local)) {
                       Rectangle()
                           .position(position)
                           .frame(width: size.width, height: size.height)
                           .foregroundColor(.blue)
                           .opacity(0.5)
                   }
               }
           }
    }
}

// MARK: - Previews
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
