//
//  InventoryView.swift
//  WasteNotMobile
//
//  Created by Ethan Yan on 12/2/25.
//

import SwiftUI

struct InventoryItem: Identifiable {
    let id = UUID()
    let name: String
    let expirationDate: String
}

struct InventoryView: View {
    let items = [
        InventoryItem(name: "Milk", expirationDate: "2025-02-15"),
        InventoryItem(name: "Eggs", expirationDate: "2025-02-20"),
        InventoryItem(name: "Spinach", expirationDate: "2025-02-13")
    ]
    
    var body: some View {
        VStack {
            // Removed duplicate title text here
            
            List(items) { item in
                HStack {
                    Text(item.name)
                    Spacer()
                    Text("Expires: \(item.expirationDate)")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                }
            }
            Button("Refresh Inventory") {
                // Simulate refresh action
            }
            .padding()
        }
        .navigationTitle("Inventory")
    }
}

struct InventoryView_Previews: PreviewProvider {
    static var previews: some View {
        InventoryView()
    }
}
