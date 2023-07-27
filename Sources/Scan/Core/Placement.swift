//
//  Placement.swift
//  
//
//  Created by Will McGinty on 3/29/23.
//

import Foundation

public struct Placement: Hashable {

    public struct Point: Hashable {

        // MARK: - Properties
        public let x: Double
        public let y: Double

        // MARK: - Initializers
        public init(x: Double, y: Double) {
            self.x = x
            self.y = y
        }

        public init(_ cgPoint: CGPoint) {
            self.init(x: cgPoint.x, y: cgPoint.y)
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
            self.init(width: size.width, height: size.height)
        }

        // MARK: - Interface
        public var cgSize: CGSize { return .init(width: width, height: height) }
    }

    // MARK: - Properties
    public let center: Point
    public let size: Size

    // MARK: - Initializers
    public init(center: Point, size: Size) {
        self.center = center
        self.size = size
    }

    public init(_ rect: CGRect) {
        self.init(center: .init(x: rect.midX, y: rect.midY), size: .init(rect.size))
    }
}
