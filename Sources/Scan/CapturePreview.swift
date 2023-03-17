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

//        public override class var layerClass: AnyClass {
//            return AVCaptureVideoPreviewLayer.self
//        }

        // MARK: - Interface
//        var videoPreviewLayer: AVCaptureVideoPreviewLayer { return layer as! AVCaptureVideoPreviewLayer }

//        func transformedMetadataObject(for metadataObject: AVMetadataObject) -> AVMetadataObject? {
//            return videoPreviewLayer.transformedMetadataObject(for: metadataObject)
//        }

        public override func layoutSubviews() {
            super.layoutSubviews()

            if let first = layer.sublayers?.first {
                first.frame = bounds
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

    // MARK: - UIViewRepresentable
    public func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()

        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.bounds


        previewLayer.session = session.captureSession
//        view.videoPreviewLayer.session = session.captureSession

        return view
    }

    public func updateUIView(_ uiView: PreviewView, context: Context) { /* No op */ }
}
