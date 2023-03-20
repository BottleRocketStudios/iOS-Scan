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

        var previewLayer: AVCaptureVideoPreviewLayer?

        // MARK: - Interface
        func insert(previewLayer newPreviewLayer: AVCaptureVideoPreviewLayer) {
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
    public let previewLayer: AVCaptureVideoPreviewLayer

    // MARK: - Initializers
    public init(session: CaptureSession, previewLayer: AVCaptureVideoPreviewLayer = .init()) {
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
        previewLayer.session = session.captureSession

        return view
    }

    public func updateUIView(_ uiView: PreviewView, context: Context) { /* No op */ }
}
