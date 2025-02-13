//
//  ScanView.swift
//  WasteNotMobile
//
//  Created by Ethan Yan on 12/2/25.
//


import SwiftUI

struct ScanView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Approach A: Scan Receipts")
                .font(.title)
                .padding(.top)
            Text("Scan your grocery receipt to auto-populate your inventory.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Scan Receipt") {
                // Simulate a scan action
            }
            .padding()
            Text("Last scan on 2025-02-20: Milk, Eggs, Bread added.")
                .foregroundColor(.gray)
            Spacer()
        }
        .navigationTitle("Scan")
        .padding()
    }
}

struct ScanView_Previews: PreviewProvider {
    static var previews: some View {
        ScanView()
    }
}
