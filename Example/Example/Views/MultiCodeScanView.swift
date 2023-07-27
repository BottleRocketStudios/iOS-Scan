//
//  MultiCodeScanView.swift
//  Example
//
//  Created by Will McGinty on 7/27/23.
//

import AVFoundation
import SwiftUI
import Scan

struct MultiCodeScanView: View {

    // MARK: - CodeScanView.ViewModel
    @MainActor
    class ViewModel: ObservableObject {

        struct IdentifiedMetadataObject: Equatable, Identifiable {
            let id: String
            let metadataObject: MachineReadableMetadataObject

            init(metadataObject: MachineReadableMetadataObject) {
                self.id = metadataObject.stringValue ?? "unknown"
                self.metadataObject = metadataObject
            }

            static func == (lhs: Self, rhs: Self) -> Bool {
                return lhs.id == rhs.id
            }
        }

        // MARK: - Properties
        let metadataCaptureSession: MetadataCaptureSession

        @Published var recognizedObjects: [IdentifiedMetadataObject] = []
        private var clearTasks: [IdentifiedMetadataObject.ID: Task<Void, Error>] = [:]

        // MARK: - Initializer
        init(metadataObjectTypes: MetadataCaptureOutput.OutputTypes) throws {
            self.metadataCaptureSession = try .defaultVideo(capturing: metadataObjectTypes)

            Task {
                for await metadataObject in metadataCaptureSession.outputStream {
                    if let readableObject = metadataObject as? MachineReadableMetadataObject {
                        let identifiedObject = IdentifiedMetadataObject(metadataObject: readableObject)
                        appendRecognizedObject(identifiedObject)
                    }
                }
            }
        }

        // MARK: - Interface
        func appendRecognizedObject(_ object: IdentifiedMetadataObject) {
            if !recognizedObjects.contains(object) {
                // If this is a new object, we'll append it to the list
                withAnimation {
                    recognizedObjects.append(object)
                }
            } else if let existing = recognizedObjects.first(where: { $0 == object }) {
                withAnimation {
                    recognizedObjects.replace([existing], with: [object])
                }
            }

            enqueueClearingOfRecognizedObject(object)
        }

        func enqueueClearingOfRecognizedObject(_ object: IdentifiedMetadataObject) {
            if let clearTask = clearTasks[object.id] {
                clearTask.cancel()
                clearTasks.removeValue(forKey: object.id)
            }

            let newClearTask = Task {
                try await Task.sleep(until: .now + .milliseconds(500), clock: .continuous)
                if !Task.isCancelled {
                    clearRecognizedObject(object)
                }
            }
            clearTasks[object.id] = newClearTask
        }

        func clearRecognizedObject(_ object: IdentifiedMetadataObject) {
            withAnimation {
                recognizedObjects.removeAll { $0 == object }
            }
        }

        func recognizeObjectPlacement(for object: IdentifiedMetadataObject) -> VideoPreviewLayer.Placement? {
            return metadataCaptureSession.transformedMetadataObjectPlacement(for: object.metadataObject)
        }
    }

    // MARK: - Properties
    @StateObject private var viewModel = try! ViewModel(metadataObjectTypes: .allAvailable)

    // MARK: - View
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea(edges: .bottom)

            viewModel.metadataCaptureSession.capturePreview
                .overlay {
                    GeometryReader { proxy in
                        ZStack {
                            ForEach(viewModel.recognizedObjects) { object in
                                if let placement = viewModel.recognizeObjectPlacement(for: object) {

                                    Rectangle()
                                        .cornerRadius(8)
                                        .foregroundStyle(.green.opacity(0.5))
                                        .border(Color.green, width: 2)
                                        .position(x: placement.position.x, y: placement.position.y)
                                        .frame(width: placement.size.width, height: placement.size.height)
                                        .animation(.default, value: placement)
                                        .foregroundStyle(.primary)
                                        .overlay {
                                            Toast(content: { toastContentView(for: object.metadataObject) }, backgroundStyle: .background, strokeStyle: .quaternary, isPresented: .constant(true))
                                                .frame(width: proxy.size.width)
                                                .position(x: placement.position.x, y: placement.position.y)
                                        }
                                }
                            }
                        }
                    }
                }
        }
        .navigationTitle("Multi Code Scanning")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Subviews
    private func toastContentView(for metadataObject: MachineReadableMetadataObject) -> some View {
        Group {
            if let stringValue = metadataObject.stringValue {
                if metadataObject.type == .qr || metadataObject.type == .microQR, let url = URL(string: stringValue) {
                    Link(destination: url) {
                        HStack {
                            Image(systemName: "qrcode")
                            Text(url.absoluteString)
                                .font(.caption2.monospaced())
                                .lineLimit(1)
                        }
                    }
                } else {
                    HStack {
                        Text(metadataObject.type.rawValue.components(separatedBy: ".").last ?? "")
                            .foregroundColor(.secondary)
                        Text(stringValue)
                    }
                    .font(.caption2.monospaced())
                }
            }
        }
    }
}

// MARK: - Previews
struct MultiCodeScanView_Previews: PreviewProvider {
    static var previews: some View {
        CodeScanView()
    }
}
