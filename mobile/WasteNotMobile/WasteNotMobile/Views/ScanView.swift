//
//  ScanView.swift
//  WasteNotMobile
//
//  Created by Ethan Yan on 7/2/25.
//


import SwiftUI

struct ScanView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Scan Receipts")
                .font(.title)
                .padding()

            Text("Placeholder for scanning barcodes/receipts...")
                .padding()

            Spacer()
        }
        .navigationTitle("Scan")
    }
}

struct ScanView_Previews: PreviewProvider {
    static var previews: some View {
        ScanView()
    }
}
