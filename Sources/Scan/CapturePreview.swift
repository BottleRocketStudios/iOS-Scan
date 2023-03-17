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

        public override class var layerClass: AnyClass {
            return AVCaptureVideoPreviewLayer.self
        }

        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
        }
    }

    // MARK: - Properties
    public let session: CaptureSession

    // MARK: - Initializer
    public init(session: CaptureSession) {
        self.session = session
    }

    // MARK: - UIViewRepresentable
    public func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.videoPreviewLayer.session = session.captureSession

        return view
    }

    public func updateUIView(_ uiView: PreviewView, context: Context) { /* No op */ }
}
