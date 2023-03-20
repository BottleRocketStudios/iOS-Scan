//
//  File.swift
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

        public override func layoutSubviews() {
            super.layoutSubviews()

            if let previewLayer = layer.sublayers?.lazy.compactMap({ $0 as? AVCaptureVideoPreviewLayer }).first {
                previewLayer.frame = bounds
            }
        }
    }

    // MARK: - Properties
    public let session: CaptureSession
    public let previewLayer: AVCaptureVideoPreviewLayer

    // MARK: - Initializer
    public init(session: CaptureSession, previewLayer: AVCaptureVideoPreviewLayer = .init()) {
        self.session = session
        self.previewLayer = previewLayer
    }

    public init(metadataCaptureSession: MetadataCaptureSession) {
        self.init(session: metadataCaptureSession.captureSession, previewLayer: metadataCaptureSession.previewLayer)
    }

    // MARK: - UIViewRepresentable
    public func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()

        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.bounds
        previewLayer.session = session.captureSession

        return view
    }

    public func updateUIView(_ uiView: PreviewView, context: Context) { /* No op */ }
}
