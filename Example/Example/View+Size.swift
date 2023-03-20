//
//  View+Size.swift
//  Example
//
//  Created by Will McGinty on 3/20/23.
//

import SwiftUI

extension View {

    func storeSize(in binding: Binding<CGSize>) -> some View {
        modifier(SizeCalculator(size: binding))
    }
}

private struct SizeCalculator: ViewModifier {

    // MARK: - Properties
    @Binding var size: CGSize

    // MARK: - ViewModifier
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .onAppear {
                            size = proxy.size
                        }
                }
            )
    }
}
