//
//  VideoPreviewLayer+Utility.swift
//  
//
//  Created by Will McGinty on 3/17/23.
//

import AVFoundation
import Foundation

public extension VideoPreviewLayer {

    // MARK: - VideoPreviewLayer + Convenience
    convenience init(cameraSession: CaptureSession, videoGravity: AVLayerVideoGravity = .resizeAspectFill) {
        self.init(session: cameraSession.captureSession)
        self.videoGravity = videoGravity
    }

    convenience init(videoGravity: AVLayerVideoGravity) {
        self.init()
        self.videoGravity = videoGravity
    }

    func transformedMetadataObjectPlacement(for object: AVMetadataObject) -> Placement? {
        return transformedMetadataObject(for: object).map { Placement($0.bounds) }
    }

    func layerPlacement(forBoundingBox boundingBox: CGRect) -> Placement {
        let layerRect = layerRectConverted(fromMetadataOutputRect: boundingBox)
        return Placement(layerRect)
    }
}
