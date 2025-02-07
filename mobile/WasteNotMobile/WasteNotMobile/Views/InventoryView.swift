//
//  InventoryView.swift
//  WasteNotMobile
//
//  Created by Ethan Yan on 7/2/25.
//


import SwiftUI

struct InventoryView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Fridge Inventory")
                .font(.title)
                .padding()

            Text("Placeholder for items sorted by expiration date...")
                .padding()

            Spacer()
        }
        .navigationTitle("Inventory")
    }
}

struct InventoryView_Previews: PreviewProvider {
    static var previews: some View {
        InventoryView()
    }
}
