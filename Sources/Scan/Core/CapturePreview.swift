//
//  CapturePreview.swift
//  
//
//  Created by Will McGinty on 3/17/23.
//

import Foundation
import SwiftUI
import AVFoundation

public struct CapturePreview: UIViewRepresentable {

    // MARK: - CapturePreview.View
    public final class PreviewView: UIView {

        private(set) var previewLayer: VideoPreviewLayer?

        // MARK: - Interface
        func insert(previewLayer newPreviewLayer: VideoPreviewLayer) {
            defer { previewLayer = newPreviewLayer }

            previewLayer?.removeFromSuperlayer()
            layer.addSublayer(newPreviewLayer)
        }

        // MARK: - Lifecycle
        public override func layoutSubviews() {
            super.layoutSubviews()

            if let previewLayer {
                previewLayer.frame = bounds
            }
        }
    }

    // MARK: - Properties
    public let session: CaptureSession
    public let previewLayer: VideoPreviewLayer

    // MARK: - Initializers
    public init(session: CaptureSession, previewLayer: VideoPreviewLayer = .init(videoGravity: .resizeAspectFill)) {
        self.session = session
        self.previewLayer = previewLayer
    }

    init(metadataCaptureSession: MetadataCaptureSession) {
        self.init(session: metadataCaptureSession.captureSession, previewLayer: metadataCaptureSession.previewLayer)
    }

    // MARK: - UIViewRepresentable
    public func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.insert(previewLayer: previewLayer)
        view.previewLayer?.session = session.captureSession

        return view
    }

    public func updateUIView(_ uiView: PreviewView, context: Context) { /* No op */ }
}
