//
//  Toast.swift
//  Example
//
//  Created by Will McGinty on 1/6/23.
//

import SwiftUI

struct Toast<Content: View, BC: ShapeStyle, SS: ShapeStyle>: View {

    // MARK: - Properties
    private let content: () -> Content
    let backgroundStyle: BC
    let strokeStyle: SS
    let autoDismissDuration: Duration?
    @Binding var isPresented: Bool

    @State private var dismissTask: Task<Void, Error>?

    // MARK: - Initializers
    init(@ViewBuilder content: @escaping () -> Content, backgroundStyle: BC, strokeStyle: SS = .clear, autoDismissDuration: Duration? = nil, isPresented: Binding<Bool>) {
        self.content = content
        self.backgroundStyle = backgroundStyle
        self.strokeStyle = strokeStyle
        self.autoDismissDuration = autoDismissDuration
        self._isPresented = isPresented
    }

    // MARK: - View
    var body: some View {
        content()
            .padding()
            .background(
                Capsule()
                    .strokeBorder(strokeStyle, lineWidth: 1.5)
                    .background(Capsule()
                        .fill(backgroundStyle)
                    )
            )
            .transition(.move(edge: .bottom).combined(with: .offset(x: 0, y: 100)))
            .onTapGesture { hideView() }
            .task {
                dismissTask = Task { @MainActor in
                    if let autoDismissDuration {
                        try await Task.sleep(until: .now + autoDismissDuration, clock: .continuous)
                        hideView()
                    }
                }
            }
    }
}

// MARK: - ModifiedLabel
struct ToastContentLabel<FC: ShapeStyle>: View {

    // MARK: - Properties
    let title: String
    let systemImage: String
    let foregroundStyle: FC

    // MARK: - View
    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.subheadline)
            .foregroundStyle(foregroundStyle)
            .contentTransition(.interpolate)
    }
}

// MARK: - Toast + Basic Configuration
extension Toast {

    // MARK: - Initializer
    init<FC: ShapeStyle>(title: String, systemImage: String, foregroundStyle: FC, backgroundStyle: BC, strokeStyle: SS = .clear,
                         autoDismissDuration: Duration? = nil, isPresented: Binding<Bool>) where Content == ToastContentLabel<FC> {
        self.init(content: {
            ToastContentLabel(title: title, systemImage: systemImage, foregroundStyle: foregroundStyle)
        }, backgroundStyle: backgroundStyle, strokeStyle: strokeStyle, autoDismissDuration: autoDismissDuration, isPresented: isPresented)
    }
}

// MARK: - Helper
private extension Toast {

    func hideView () {
        if isPresented {
            dismissTask?.cancel()
            dismissTask = nil

            withAnimation {
                isPresented = false
            }
        }
    }
}

// MARK: - Previews
struct Toast_Previews: PreviewProvider {

    static var previews: some View {
        VStack {
            Toast(title: "www.bottlerocketstudios.com", systemImage: "link", foregroundStyle: .primary, backgroundStyle: .background,
                  autoDismissDuration: nil, isPresented: .constant(true))

            Toast(title: "www.bottlerocketstudios.com", systemImage: "link", foregroundStyle: .primary, backgroundStyle: .background,
                  autoDismissDuration: nil, isPresented: .constant(true))
            .environment(\.colorScheme, .dark)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
