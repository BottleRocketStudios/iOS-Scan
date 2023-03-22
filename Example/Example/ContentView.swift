//
//  ContentView.swift
//  Example
//
//  Created by Will McGinty on 3/17/23.
//

import AVFoundation
import SwiftUI
import Scan

struct ContentView: View {

    enum Destination {
        case codeScan
        case cardScan
    }

    // MARK: - View
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Code Scanning", value: Destination.codeScan)
                NavigationLink("Card Scan", value: Destination.cardScan)
            }
            .navigationTitle("Examples")
            .navigationDestination(for: Destination.self) { destination in
                switch destination {
                case .codeScan: CodeScanView()
                case .cardScan: VisionView()

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
