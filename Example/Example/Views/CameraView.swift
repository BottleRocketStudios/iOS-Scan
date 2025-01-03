//
//  CameraView.swift
//  Example
//
//  Created by Will McGinty on 1/2/25.
//

import Scan
import SwiftUI

struct CameraView: View {

    // MARK: - ViewModel
    @Observable
    fileprivate class ViewModel {

        // MARK: - Properties
        let photoCaptureSession: PhotoCaptureSession
        var lastCapturedPhoto: UIImage?

        // MARK: - Initializer
        init() throws {
            self.photoCaptureSession = try
                .defaultPhoto(captureSessionConfiguration: .init(preset: .photo), previewVideoGravity: .resizeAspectFill)

            Task {
                for await photo in photoCaptureSession.outputStream {
                    lastCapturedPhoto = UIImage(data: photo)
                }
            }
        }

        // MARK: - Interface
        func capture() {
            photoCaptureSession.photoOutput.capturePhoto()
        }
    }

    // MARK: - Properties
    private let viewModel = try! ViewModel()

    // MARK: - View
    var body: some View {
        ZStack {
            // Camera Preview
            viewModel.photoCaptureSession.capturePreview
                .ignoresSafeArea()

            // Capture Button
            VStack {
                Spacer()
                Button(action: { withAnimation { viewModel.capture() } }) {
                    Circle()
                        .fill(.white)
                        .frame(width: 80, height: 80)
                        .overlay(
                            Circle()
                                .stroke(Color.gray.opacity(0.7), lineWidth: 3)
                        )
                        .shadow(radius: 5)
                        .scaleEffect(0.95)
                        .animation(.spring(), value: viewModel.lastCapturedPhoto)
                }
                .padding(.bottom, 40)
                .buttonStyle(.plain)
            }
        }
        .overlay(alignment: .bottomLeading) {
            // Last Captured Photo
            if let lastCapturedPhoto = viewModel.lastCapturedPhoto {
                Image(uiImage: lastCapturedPhoto)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 5)
                    .frame(width: 70)
                    .transition(.blurReplace)
                    .padding()
            }
        }
    }
}
