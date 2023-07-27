//
//  TestView.swift
//  Example
//
//  Created by Will McGinty on 4/10/23.
//

import SwiftUI
import Scan
import Vision

struct TestView: View {

    // MARK: - ContentView.ViewModel
    @MainActor
    class ViewModel: ObservableObject {

        // MARK: - Properties
        let image: UIImage
        private lazy var requestHandler = VNImageRequestHandler(ciImage: CIImage(image: image)!, orientation: .init(image.imageOrientation))

        @Published var boxCount: Int = 0
        @Published var boundingBoxes: [CGRect] = []

        // MARK: - Initializer
        init(image: UIImage) {
            self.image = image

            Task {
                let detectRectangleRequest = VNDetectRectanglesRequest()
                let paymentCardAspectRatio: Float = 85.6 / 53.98
                detectRectangleRequest.minimumAspectRatio = paymentCardAspectRatio * 0.90
                detectRectangleRequest.maximumAspectRatio = paymentCardAspectRatio * 1.10

                try requestHandler.perform([detectRectangleRequest])
                print(detectRectangleRequest.results)

                self.boundingBoxes = detectRectangleRequest.results?.map(\.boundingBox).map { .init(x: $0.origin.x, y: 1 - $0.origin.y, width: $0.width, height: $0.height) } ?? []
                self.boxCount = boundingBoxes.count
            }
        }
    }

    // MARK: - Properties
    @StateObject private var viewModel = ViewModel(image: UIImage(named: "Image")!)

    // MARK: - View
    var body: some View {
        ZStack {
            Image(uiImage: viewModel.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .overlay(alignment: .topLeading) {
                    Text(viewModel.boxCount.formatted())
                }
                .overlay {
                    GeometryReader { proxy in
                        ForEach(viewModel.boundingBoxes, id: \.self) { box in

                            let rect = VNImageRectForNormalizedRect(box, Int(proxy.size.width), Int(proxy.size.height))
//                            let _ = print(rect)

                            let scaled = rect//.applying(.init(scaleX: 0.25, y: 0.25))
                            let _ = print(scaled)

                            Rectangle()
                                .cornerRadius(8)
                                .foregroundColor(.green.opacity(0.5))
                                .border(Color.green, width: 2)
                                .position(.init(x: scaled.midX,
                                                y: scaled.midY))
                                .frame(width: scaled.width, height: scaled.height)

                        }
                    }
                }
        }
        .navigationTitle("Test")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension CGRect: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(minX)
        hasher.combine(minY)
        hasher.combine(width)
        hasher.combine(height)
    }
}

// MARK: - Previews
struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}

extension UIImage {
    func fixedOrientation() -> UIImage? {
        guard imageOrientation != UIImage.Orientation.up else {
            //This is default orientation, don't need to do anything
            return self.copy() as? UIImage
        }
        guard let cgImage = self.cgImage else {
            //CGImage is not available
            return nil
        }

        return UIImage(cgImage: cgImage)
    }
}

extension CGImagePropertyOrientation {
    init(_ uiOrientation: UIImage.Orientation) {
        switch uiOrientation {
            case .up: self = .up
            case .upMirrored: self = .upMirrored
            case .down: self = .down
            case .downMirrored: self = .downMirrored
            case .left: self = .left
            case .leftMirrored: self = .leftMirrored
            case .right: self = .right
            case .rightMirrored: self = .rightMirrored
        @unknown default:
            fatalError("what is this")
        }
    }
}
