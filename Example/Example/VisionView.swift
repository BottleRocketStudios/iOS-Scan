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
        let videoCaptureSession: VideoCaptureSession
        private let requestHandler = VNSequenceRequestHandler()
        
        @Published var pixelBufferSize: CGSize?
        @Published var previewLayerFrame: CGRect?
        @Published var recognizedObjectRect: CGRect?
        @Published var processedObjectRect: CGRect?
        
        // MARK: - Initializer
        init() throws {
            self.videoCaptureSession = try .defaultVideo()
            
            Task {
                for await pixelBuffer in videoCaptureSession.outputStream {
                    let rectangleDetectionRequest = VNDetectRectanglesRequest()
                    let paymentCardAspectRatio: Float = 85.6 / 53.98
                    rectangleDetectionRequest.minimumAspectRatio = paymentCardAspectRatio * 0.95
                    rectangleDetectionRequest.maximumAspectRatio = paymentCardAspectRatio * 1.10

                    let textDetectionRequest = VNDetectTextRectanglesRequest()
                    
                    self.pixelBufferSize = .init(width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
                    self.previewLayerFrame = videoCaptureSession.previewLayer.frame
                    
                    try? requestHandler.perform([rectangleDetectionRequest, textDetectionRequest], on: pixelBuffer)

                    guard let recognizedRectangle = rectangleDetectionRequest.results?.sorted(by: { $0.confidence < $1.confidence }).first(where: { rectangleObservation in
                        return textDetectionRequest.results?.contains { rectangleObservation.boundingBox.contains($0.boundingBox) } ?? false
                    }) else {
                        self.recognizedObjectRect = nil
                        self.processedObjectRect = nil
                        continue
                    }
                    
                    let processedRect = videoCaptureSession.transformedViewRect(forNormalizedBoundingBox: recognizedRectangle.boundingBox)
                    self.recognizedObjectRect = recognizedRectangle.boundingBox
                    self.processedObjectRect = processedRect
                }
            }
        }
    }
    
    // MARK: - Properties
    @StateObject private var viewModel = try! ViewModel()
    
    // MARK: - View
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea(edges: .bottom)

            viewModel.videoCaptureSession.capturePreview
                .overlay {
                    GeometryReader { proxy in
                        if let rect = viewModel.processedObjectRect {
                            Rectangle()
                                .cornerRadius(8)
                                .foregroundColor(.green.opacity(0.5))
                                .border(Color.green, width: 2)
                                .position(x: rect.midX, y: rect.midY)
                                .frame(width: rect.width, height: rect.height)
                                .animation(.default, value: rect)
                        }
                    }
                }
                .overlay(alignment: .top) {
                    if viewModel.pixelBufferSize != nil || viewModel.previewLayerFrame != nil || viewModel.recognizedObjectRect != nil || viewModel.processedObjectRect != nil {
                        VStack {
                            if let bufferSize = viewModel.pixelBufferSize {
                                text(for: bufferSize, label: "Buffer Size")
                                    .animation(nil, value: bufferSize)
                            }

                            if let previewFrame = viewModel.previewLayerFrame {
                                text(for: previewFrame, label: "Preview")
                                    .animation(nil, value: previewFrame)
                            }

                            if let recognized = viewModel.recognizedObjectRect {
                                text(for: recognized, label: "Recognized")
                                    .animation(nil, value: recognized)
                            }

                            if let processed = viewModel.processedObjectRect {
                                text(for: processed, label: "Processed")
                                    .animation(nil, value: processed)
                            }
                        }
                        .font(.caption)
                        .padding()
                        .background(Material.regular)
                        .cornerRadius(12)
                        .padding()
                        .animation(.default, value: viewModel.pixelBufferSize)
                        .animation(.default, value: viewModel.previewLayerFrame)
                        .animation(.default, value: viewModel.recognizedObjectRect)
                        .animation(.default, value: viewModel.processedObjectRect)
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
