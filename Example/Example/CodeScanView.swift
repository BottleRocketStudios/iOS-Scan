//
//  CodeScanView.swift
//  Example
//
//  Created by Will McGinty on 3/21/23.
//

import AVFoundation
import SwiftUI
import Scan

struct CodeScanView: View {

    // MARK: - ContentView.ViewModel
    @MainActor
    class ViewModel: ObservableObject {

        // MARK: - Properties
        let metadataCaptureSession: MetadataCaptureSession?

        @Published var recognizedObject: MetadataObject.MachineReadableCode?
        private var clearTask: Task<Void, Error>?

        // MARK: - Initializer
        init(metadataObjectTypes: MetadataCaptureOutput.OutputTypes) {
            self.metadataCaptureSession = try? .defaultVideo(capturing: metadataObjectTypes)

            if let outputStream = metadataCaptureSession?.outputStream {
                Task {
                    for await metadataObject in outputStream {
                        switch metadataObject {
                        case .machineReadableCode(let code): setRecognizedObject(code)
                        default: continue
                        }
                    }
                }
            }
        }

        // MARK: - Interface
        func setRecognizedObject(_ object: MetadataObject.MachineReadableCode?) {
            withAnimation {
                recognizedObject = object
            }

            if recognizedObject != nil {
                clearTask?.cancel()
                clearTask = Task {
                    try await Task.sleep(until: .now + .seconds(1), clock: .continuous)
                    setRecognizedObject(nil)
                }
            }
        }

        var recognizeObjectPlacement: Placement? {
            return recognizedObject.flatMap {
                return metadataCaptureSession?.layerPlacement(forBoundingBox: $0.bounds)
            }
        }
    }

    // MARK: - Properties
    @StateObject private var viewModel = ViewModel(metadataObjectTypes: .allAvailable)

    @State private var isPresentingToast: Bool = false
    @State private var cutoutSize: CGSize = .zero

    // MARK: - Interface
    func updateCutoutSize(in rect: CGRect) {
        let newCutoutSize = CGSize(width: rect.size.width * 0.5, height: rect.size.width * 0.5)
        let newCutoutRect = CGRect(origin: .init(x: rect.midX - (0.5 * newCutoutSize.width), y: rect.midY - (0.5 * newCutoutSize.width)), size: newCutoutSize)

        cutoutSize = newCutoutSize
        viewModel.metadataCaptureSession?.setViewRectOfInterest(newCutoutRect)
    }

    // MARK: - View
    var body: some View {
         ZStack {
            if let metadataCaptureSession = viewModel.metadataCaptureSession {
                metadataCaptureSession.capturePreview
                    .overlay {
                        GeometryReader { proxy in
                            Color.black
                                .opacity(0.5)
                                .clipShape(CutoutRoundedRectangle(cutoutSize: cutoutSize), style: FillStyle(eoFill: true))
                                .task { updateCutoutSize(in: proxy.frame(in: .local)) }
                        }
                    }
                    .overlay {
                        GeometryReader { proxy in
                            if let placement = viewModel.recognizeObjectPlacement {
                                Rectangle()
                                    .cornerRadius(8)
                                    .foregroundColor(.green.opacity(0.5))
                                    .border(Color.green, width: 2)
                                    .placement(placement)
                                    .animation(.default, value: placement)
                            }
                        }
                    }
                    .ignoresSafeArea(edges: .bottom)
                    .overlay(alignment: .bottom) {
                        if let recognizedObject = viewModel.recognizedObject {
                            Toast(content: { toastContentView(for: recognizedObject) }, backgroundColor: .white, isPresented: $isPresentingToast)
                        }
                    }
            } else {
                Text("Metadata capture not supported")
            }
        }
        .navigationTitle("Code Scanning")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Subviews
    private func toastContentView(for metadataObject: MetadataObject.MachineReadableCode) -> some View {
        Group {
            if let stringValue = metadataObject.stringValue {
                if metadataObject.kind == .qr || metadataObject.kind == .microQR, let url = URL(string: stringValue) {
                    Link(destination: url) {
                        HStack {
                            Image(systemName: "qrcode")
                            Text(url.absoluteString)
                                .font(.caption2.monospaced())
                        }
                    }
                } else {
                    HStack {
                        Text(metadataObject.kind.rawValue.components(separatedBy: ".").last ?? "")
                            .foregroundColor(.secondary)
                        Text(stringValue)
                    }
                    .font(.caption2.monospaced())
                }
            }
        }
    }
}

// MARK: - CutoutRoundedRectangle
private struct CutoutRoundedRectangle: Shape {

    var cornerRadius: CGFloat = 16
    var cutoutSize: CGSize = .zero

    func path(in rect: CGRect) -> Path {
        Path { path in
            path.addPath(Rectangle().path(in: rect))

            let cutout = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .path(in: .init(x: rect.midX - (0.5 * cutoutSize.width), y: rect.midY - (0.5 * cutoutSize.height),
                                width: cutoutSize.width, height: cutoutSize.height))

            path.addPath(cutout)
        }
    }
}

// MARK: - Previews
struct CodeScanView_Previews: PreviewProvider {
    static var previews: some View {
        CodeScanView()
    }
}
