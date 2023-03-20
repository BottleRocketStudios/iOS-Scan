//
//  AVCaptureVideoPreviewLayer+Utility.swift
//  
//
//  Created by Will McGinty on 3/17/23.
//

import AVFoundation
import Foundation

public extension AVCaptureVideoPreviewLayer {

    convenience init(cameraSession: CaptureSession, videoGravity: AVLayerVideoGravity = .resizeAspectFill) async {
        self.init(session: cameraSession.captureSession)
        self.videoGravity = videoGravity
    }


    struct Placement: Hashable {

        public struct Point: Hashable {

            // MARK: - Properties
            public let x: Double
            public let y: Double

            // MARK: - Initializer
            public init(x: Double, y: Double) {
                self.x = x
                self.y = y
            }

            // MARK: - Interface
            public var cgPoint: CGPoint { return .init(x: x, y: y) }
        }

        public struct Size: Hashable {

            // MARK: - Properties
            public let width: Double
            public let height: Double

            // MARK: - Initializers
            public init(width: Double, height: Double) {
                self.width = width
                self.height = height
            }

            init(_ size: CGSize) {
                self.width = size.width
                self.height = size.height
            }

            // MARK: - Interface
            public var cgSize: CGSize { return .init(width: width, height: height) }
        }
        
        // MARK: - Properties
        public let position: Point
        public let size: Size
    }

    func transformedMetadataObjectPlacement(for object: AVMetadataObject) -> Placement? {
        return transformedMetadataObject(for: object).map {
            return .init(position: .init(x: $0.bounds.midX, y: $0.bounds.midY),
                         size: .init($0.bounds.size))
        }
    }
}
