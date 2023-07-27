//
//  VisionView.swift
//  Example
//
//  Created by Will McGinty on 3/21/23.
//

import SwiftUI
import Scan
import Vision

struct VisionView: View {
    
    // MARK: - ContentView.ViewModel
    @MainActor
    class ViewModel: ObservableObject {
        
        // MARK: - Properties
        let videoCaptureSession: VideoCaptureSession?
        private let requestHandler = VNSequenceRequestHandler()
        
        @Published var pixelBufferSize: CGSize?
        @Published var previewLayerFrame: CGRect?
        @Published var recognizedObjectRect: CGRect?
        @Published var processedObjectPlacement: Placement?
        
        // MARK: - Initializer
        init() {
            self.videoCaptureSession = try? .defaultVideo()

            if let videoCaptureSession {
                Task {
                    for await pixelBuffer in videoCaptureSession.outputStream {
                        let rectangleDetectionRequest = VNDetectRectanglesRequest()
                        let paymentCardAspectRatio: Float = 85.6 / 53.98
                        rectangleDetectionRequest.minimumAspectRatio = paymentCardAspectRatio * 0.90
                        rectangleDetectionRequest.maximumAspectRatio = paymentCardAspectRatio * 1.10

                        let textDetectionRequest = VNDetectTextRectanglesRequest()

                        self.pixelBufferSize = .init(width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
                        self.previewLayerFrame = videoCaptureSession.previewLayer.frame

                        try? requestHandler.perform([rectangleDetectionRequest, textDetectionRequest], on: pixelBuffer)

                        guard let recognizedRectangle = rectangleDetectionRequest.results?.sorted(by: { $0.confidence < $1.confidence }).first(where: { rectangleObservation in
                            return textDetectionRequest.results?.contains { rectangleObservation.boundingBox.contains($0.boundingBox) } ?? false
                        }) else {
                            self.recognizedObjectRect = nil
                            self.processedObjectPlacement = nil
                            continue
                        }

                        let processedPlacement = videoCaptureSession.transformedPlacement(forNormalizedBoundingBox: recognizedRectangle.boundingBox)
                        self.processedObjectPlacement = processedPlacement
                        self.recognizedObjectRect = recognizedRectangle.boundingBox
                    }
                }
            }
        }
    }
    
    // MARK: - Properties
    @StateObject private var viewModel = ViewModel()
    
    // MARK: - View
    var body: some View {
        ZStack {
            if let videoCaptureSession = viewModel.videoCaptureSession {
                videoCaptureSession.capturePreview
                    .overlay {
                        GeometryReader { proxy in
                            if let placement = viewModel.processedObjectPlacement {
                                Rectangle()
                                    .cornerRadius(8)
                                    .foregroundColor(.blue.opacity(0.5))
                                    .border(Color.green, width: 2)
                                    .placement(placement)
                                    .animation(.default, value: placement)
                            }
                        }
                    }
                    .ignoresSafeArea(edges: .bottom)
                    .overlay(alignment: .bottom) {
                        if viewModel.pixelBufferSize != nil || viewModel.previewLayerFrame != nil
                            || viewModel.recognizedObjectRect != nil || viewModel.processedObjectPlacement != nil {
                            VStack {
                                if let pixelBufferSize = viewModel.pixelBufferSize {
                                    text(for: pixelBufferSize, label: "Pixel Buffer")
                                }

                                if let previewLayerFrame = viewModel.previewLayerFrame {
                                    text(for: previewLayerFrame, label: "Preview Layer")
                                }

                                if let recognizedObjectRect = viewModel.recognizedObjectRect {
                                    text(for: recognizedObjectRect, label: "Recognized Object")
                                }

                                if let processedObjectPlacement = viewModel.processedObjectPlacement {
                                    text(for: processedObjectPlacement, label: "Processed Object")
                                }
                            }
                            .font(.caption)
                            .padding()
                            .background(Material.ultraThin)
                            .cornerRadius(12)
                        }
                    }
            }
        }
        .navigationTitle("Vision")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Helper
private extension VisionView {
    
    func text(for rect: CGRect, with formatStyle: FloatingPointFormatStyle<CGFloat> = .init().precision(.fractionLength(0...1)), label: String) -> some View {
        Text("\(label) X: \(rect.minX.formatted(formatStyle)) Y: \(rect.minY.formatted(formatStyle)) Width: \(rect.width.formatted(formatStyle)) Height: \(rect.height.formatted(formatStyle))")
    }

    func text(for placement: Placement, with formatStyle: FloatingPointFormatStyle<CGFloat> = .init().precision(.fractionLength(0...1)), label: String) -> some View {
        Text("\(label) X: \(placement.center.x.formatted(formatStyle)) Y: \(placement.center.y.formatted(formatStyle)) Width: \(placement.size.width.formatted(formatStyle)) Height: \(placement.size.height.formatted(formatStyle))")
    }
    
    func text(for size: CGSize, with formatStyle: FloatingPointFormatStyle<CGFloat> = .init().precision(.fractionLength(0...1)), label: String) -> some View {
        Text("\(label) Width: \(size.width.formatted(formatStyle)) Height: \(size.height.formatted(formatStyle))")
    }
}

// MARK: - Previews
struct VisionView_Previews: PreviewProvider {
    static var previews: some View {
        VisionView()
    }
}
