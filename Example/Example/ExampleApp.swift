//
//  ExampleApp.swift
//  Example
//
//  Created by Will McGinty on 3/17/23.
//

import AVFoundation
import SwiftUI

@main
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// MARK: - ContentView
struct ContentView: View {

    // MARK: - ContentView.Destination
    enum Destination {
        case codeScan
        case multiCodeScan
    }

    // MARK: - View
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Code Scanning", value: Destination.codeScan)
                NavigationLink("Multi Code Scanning", value: Destination.multiCodeScan)
            }
            .navigationTitle("Examples")
            .navigationDestination(for: Destination.self) { destination in
                switch destination {
                case .codeScan: CodeScanView()
                case .multiCodeScan: MultiCodeScanView()
                }
            }
        }
    }
}

// MARK: - Previews
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
