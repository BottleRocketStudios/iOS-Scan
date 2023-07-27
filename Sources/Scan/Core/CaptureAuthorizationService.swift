//
//  CaptureAuthorizationService.swift
//  
//
//  Created by Will McGinty on 3/17/23.
//

import AVFoundation

public typealias AuthorizationStatus = AVAuthorizationStatus
public typealias MediaType = AVMediaType

public class CaptureAuthorizationService: ObservableObject {

    // MARK: - Properties
    public let mediaType: MediaType
    @Published public var authorizationStatus: AVAuthorizationStatus

    // MARK: - Initializer
    public init(requestedMediaType: MediaType) {
        mediaType = requestedMediaType
        authorizationStatus = Self.authorizationStatus(for: requestedMediaType)
    }

    // MARK: - Interface
    public func requestAuthorization() async -> AuthorizationStatus {
        guard authorizationStatus == .notDetermined else {
            return authorizationStatus
        }

        _ = await AVCaptureDevice.requestAccess(for: mediaType)

        let updatedAuthorizationStatus = Self.authorizationStatus(for: mediaType)
        authorizationStatus = updatedAuthorizationStatus
        return updatedAuthorizationStatus
    }
}

// MARK: - Helper
private extension CaptureAuthorizationService {

    static func authorizationStatus(for mediaType: MediaType) -> AuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(for: mediaType)
    }
}

// MARK: - AVAuthorizationStatus + Convenience
public extension AVAuthorizationStatus {

    var isGranted: Bool {
        switch self {
        case .authorized: return true
        default: return false
        }
    }
}
