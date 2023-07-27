//
//  MetadataObject.swift
//  
//
//  Created by Will McGinty on 3/29/23.
//

import AVFoundation
import CoreImage
import Foundation

public enum MetadataObject {

    // MARK: - MetadataObject.Kind
    public typealias Kind = AVMetadataObject.ObjectType

    // MARK: - MetadataObject.MachineReadable
    public struct MachineReadableCode {

        // MARK: - Properties
        public let kind: Kind
        public let bounds: CGRect
        public let corners: [CGPoint]
        public let stringValue: String?
        public let descriptor: CIBarcodeDescriptor?

        // MARK: - Initializer
        init(_ object: AVMetadataMachineReadableCodeObject) {
            self.kind = object.type
            self.bounds = object.bounds
            self.corners = object.corners
            self.stringValue = object.stringValue
            self.descriptor = object.descriptor
        }
    }

    // MARK: - MetadataObject.Face
    public struct Face: Identifiable {

        // MARK: - Properties
        public let id: Int
        public let kind: Kind
        public let bounds: CGRect
        public let rollAngle: CGFloat?
        public let yawAngle: CGFloat?

        // MARK: - Initializer
        init(_ object: AVMetadataFaceObject) {
            self.id = object.faceID
            self.kind = object.type
            self.bounds = object.bounds
            self.rollAngle = object.hasRollAngle ? object.rollAngle : nil
            self.yawAngle = object.hasYawAngle ? object.yawAngle : nil
        }
    }

    // MARK: - MetadataObject.Body
    public struct Body: Identifiable {

        // MARK: - Properties
        public let id: Int
        public let kind: Kind
        public let bounds: CGRect

        // MARK: - Initializer
        init(_ object: AVMetadataBodyObject) {
            self.id = object.bodyID
            self.kind = object.type
            self.bounds = object.bounds
        }
    }

    // MARK: - MetadataObject.Salient
    public struct Salient: Identifiable {

        // MARK: - Properties
        public let id: Int
        public let kind: Kind
        public let bounds: CGRect

        // MARK: - Initializer
        init(_ object: AVMetadataSalientObject) {
            self.id = object.objectID
            self.kind = object.type
            self.bounds = object.bounds
        }
    }

    case machineReadableCode(MachineReadableCode)
    case face(Face)
    case body(Body)
    case catBody(Body)
    case dogBody(Body)
    case humanBody(Body)
    case salient(Salient)

    // MARK: - Initializer
    init?(_ object: AVMetadataObject) {
        if let machineReadableObject = object as? AVMetadataMachineReadableCodeObject {
            self = .machineReadableCode(.init(machineReadableObject))
        } else if let faceObject = object as? AVMetadataFaceObject {
            self = .face(.init(faceObject))
        } else if let bodyObject = object as? AVMetadataBodyObject {
            self = .body(.init(bodyObject))
        } else if let catBodyObject = object as? AVMetadataCatBodyObject {
            self = .catBody(.init(catBodyObject))
        } else if let dogBodyObject = object as? AVMetadataDogBodyObject {
            self = .dogBody(.init(dogBodyObject))
        } else if let humanBodyObject = object as? AVMetadataHumanBodyObject {
            self = .humanBody(.init(humanBodyObject))
        } else if let salientObject = object as? AVMetadataSalientObject {
            self = .salient(.init(salientObject))
        } else {
            return nil
        }
    }
}
