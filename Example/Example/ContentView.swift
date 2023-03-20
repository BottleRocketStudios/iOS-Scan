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
        let metadataCaptureSession: MetadataCaptureSession

        @Published var recognizedObject: AVMetadataMachineReadableCodeObject?
        private var clearTask: Task<Void, Error>?

        // MARK: - Initializer
        init(metadataObjectTypes: [MetadataCaptureOutput.ObjectType]) throws {
            self.metadataCaptureSession = try .init(metadataTypes: metadataObjectTypes)

            Task {
                for await metadataObject in metadataCaptureSession.outputStream {
                    if let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject {
                        setRecognizedObject(readableObject)
                    }
                }
            }
        }

        // MARK: - Interface
        func setRecognizedObject(_ object: AVMetadataMachineReadableCodeObject?) {
            withAnimation {
                recognizedObject = object
            }

            if recognizedObject != nil {
                clearTask?.cancel()
                clearTask = Task {
                    try await Task.sleep(until: .now + .seconds(2), clock: .continuous)
                    setRecognizedObject(nil)
                }
            }
        }

        var recognizeObjectPlacement: AVCaptureVideoPreviewLayer.Placement? {
            return recognizedObject.flatMap {
                metadataCaptureSession.transformedMetadataObjectPlacement(for: $0)
            }
        }
    }

    // MARK: - Properties
    @StateObject private var viewModel = try! ViewModel(metadataObjectTypes: [.qr])
    @State private var isPresentingToast: Bool = false

    // MARK: - View
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            CapturePreview(metadataCaptureSession: viewModel.metadataCaptureSession)
                .overlay {
                    GeometryReader { proxy in
                        if let placement = viewModel.recognizeObjectPlacement {
                            Rectangle()
                                .position(x: placement.position.x, y: placement.position.y)
                                .frame(width: placement.size.width, height: placement.size.height)
                                .foregroundColor(.blue)
                                .opacity(0.5)
                                .animation(.default, value: placement)
                        }
                    }
                }
                .overlay(alignment: .bottom) {
                    if let urlString = viewModel.recognizedObject?.stringValue, let url = URL(string: urlString) {
                        Toast(content: { Link(destination: url, label: { Label(urlString, systemImage: "safari.fill") }) },
                              backgroundColor: .white, isPresented: $isPresentingToast)
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
