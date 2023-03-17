//
//  AVCaptureVideoPreviewLayer+Utility.swift
//  
//
//  Created by Will McGinty on 3/17/23.
//

import AVFoundation

public extension AVCaptureVideoPreviewLayer {

    convenience init(cameraSession: CaptureSession, videoGravity: AVLayerVideoGravity = .resizeAspectFill) async {
        self.init(session: cameraSession.captureSession)
        self.videoGravity = videoGravity
    }
}
