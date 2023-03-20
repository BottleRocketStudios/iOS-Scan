//
//  Toast.swift
//  QSR
//
//  Created by Will McGinty on 1/6/23.
//

import SwiftUI

struct Toast<Content>: View where Content: View {

    // MARK: - Properties
    private let content: () -> Content
    let backgroundColor: Color
    let autoDismissDuration: Duration?
    @Binding var isPresented: Bool

    @State private var dismissTask: Task<Void, Error>?

    // MARK: - Initializers
    init(@ViewBuilder content: @escaping () -> Content, backgroundColor: Color, autoDismissDuration: Duration? = nil, isPresented: Binding<Bool>) {
        self.content = content
        self.autoDismissDuration = autoDismissDuration
        self.backgroundColor = backgroundColor
        self._isPresented = isPresented
    }

    // MARK: - View
    var body: some View {
        content()
            .padding()
            .clipShape(Capsule())
            .background(
                Capsule()
                    .strokeBorder(.white, lineWidth: 1.5)
                    .background(Capsule()
                        .fill(backgroundColor)
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

// MARK: - Toast + Basic Configuration
extension Toast {

    private struct ModifiedLabel: View {

        // MARK: - Properties
        let title: String
        let systemImage: String
        let backgroundColor: Color

        // MARK: - View
        var body: some View {
            Label(title, systemImage: systemImage)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }

    init(title: String, systemImage: String, backgroundColor: Color, autoDismissDuration: Duration? = nil, isPresented: Binding<Bool>) where Content == AnyView {
        self.init(content: {
            AnyView(
                ModifiedLabel(title: title, systemImage: systemImage, backgroundColor: backgroundColor)
            )
        }, backgroundColor: backgroundColor, autoDismissDuration: autoDismissDuration, isPresented: isPresented)
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
            Toast(title: "Copied to Clipboard", systemImage: "link", backgroundColor: .red, autoDismissDuration: nil, isPresented: .constant(true))
            Toast(title: "Copied to Clipboard", systemImage: "link", backgroundColor: .red, autoDismissDuration: nil, isPresented: .constant(true))
                .environment(\.colorScheme, .dark)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
