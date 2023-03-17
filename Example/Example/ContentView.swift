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

        // MARK: - Initializer
        init(capturingMediaType: MediaType) {
            self.authorizationService = .init(requestedMediaType: capturingMediaType)
            self.captureSession = CaptureSession(configuration: .init(preset: .high))

            Task {
                guard let cameraInput = try? CameraCaptureInput.default(forCapturing: capturingMediaType) else { return }

                await captureSession.addInput(cameraInput)
                await captureSession.startRunning()
            }
        }
    }

    // MARK: - Properties
    @StateObject var viewModel = ViewModel(capturingMediaType: .video)

    // MARK: - View
    var body: some View {
        CapturePreview(session: viewModel.captureSession)
           .ignoresSafeArea()
           .task {
               _ = await viewModel.authorizationService.requestAuthorization()
           }
    }
}

// MARK: - Previews
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
