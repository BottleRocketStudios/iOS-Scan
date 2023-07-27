//
//  View+Placement.swift
//  
//
//  Created by Will McGinty on 3/28/23.
//

import SwiftUI

public extension View {

    func placement(_ placement: Placement) -> some View {
        self
            .position(x: placement.center.x, y: placement.center.y)
            .frame(width: placement.size.width, height: placement.size.height)
    }
}
