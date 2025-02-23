//
//  ScanView.swift
//  WasteNotMobile
//
//  Created by Ethan Yan on 23/2/25.
//

import SwiftUI
import AVFoundation

struct ScanView: View {
    @State private var scannedCode: String? = nil
    @State private var isShowingConfirmation = false
    
    var body: some View {
        NavigationView {
            VStack {
                if let code = scannedCode {
                    Text("Scanned Code: \(code)")
                        .font(.headline)
                        .padding()
                } else {
                    Text("Scanning for barcode...")
                        .padding()
                }
                
                BarcodeScannerView(scannedCode: $scannedCode, isShowingConfirmation: $isShowingConfirmation)
                    .cornerRadius(12)
                    .padding()
                
                // NavigationLink to the ConfirmationView
                NavigationLink(
                    destination: ConfirmationView(scannedCode: scannedCode ?? "", onCompletion: {
                        // Reset after confirmation
                        scannedCode = nil
                        isShowingConfirmation = false
                    }),
                    isActive: $isShowingConfirmation,
                    label: { EmptyView() }
                )
                
                // Reset Scanner Button
                Button("Reset Scanner") {
                    scannedCode = nil
                    isShowingConfirmation = false
                }
                .padding()
                .foregroundColor(.blue)
            }
            .navigationTitle("Scan Barcode")
        }
    }
}
