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
        case camera
        case codeScan
        case multiCodeScan
    }

    @State private var isPresentingCodeScanning: Bool = false
    @State private var isPresentingMultiCodeScanning: Bool = false

    // MARK: - View
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Code Scanning", value: Destination.codeScan)
                NavigationLink("Multi Code Scanning", value: Destination.multiCodeScan)
                NavigationLink("Camera", value: Destination.camera)

                Section {
                    Button("Code Scanning Sheet") {
                        isPresentingCodeScanning.toggle()
                    }

                    Button("Multi Code Scanning Sheet") {
                        isPresentingMultiCodeScanning.toggle()
                    }
                }
            }
            .navigationTitle("Examples")
            .navigationDestination(for: Destination.self) { destination in
                switch destination {
                case .camera: CameraView()
                case .codeScan: CodeScanView()
                case .multiCodeScan: MultiCodeScanView()
                }
            }
            .sheet(isPresented: $isPresentingCodeScanning) {
                NavigationStack {
                    CodeScanView()
                        .navigationTitle("Code Scanning")
                }
            }
            .sheet(isPresented: $isPresentingMultiCodeScanning) {
                NavigationStack {
                    MultiCodeScanView()
                        .navigationTitle("Multi Code Scanning")
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
