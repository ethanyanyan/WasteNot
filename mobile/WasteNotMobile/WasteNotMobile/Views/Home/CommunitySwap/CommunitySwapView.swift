//
//  CommunitySwapView.swift
//  WasteNotMobile
//
//  Created by Ethan Yan on 12/2/25.
//

import SwiftUI

// Data model for a swap item
struct SwapItem: Identifiable {
    let id = UUID()
    let title: String
    let expirationDate: String
    let imageName: String // For mock images; you could use systemName or asset names.
}

// Custom row view for each swap item listing
struct SwapItemRow: View {
    var item: SwapItem
    
    var body: some View {
        HStack {
            // Display a mock image thumbnail
            Image(systemName: item.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .padding(.trailing, 8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                Text("Expires: \(item.expirationDate)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Button("Contact") {
                // Simulate a contact action (e.g., show alert or navigate)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
        .padding(.vertical, 8)
    }
}

struct CommunitySwapView: View {
    // Mock data for community swap listings
    let swapItems = [
        SwapItem(title: "John's Apples", expirationDate: "2025-02-12", imageName: "applelogo"),
        SwapItem(title: "Sarah's Bread", expirationDate: "2025-02-14", imageName: "bag.fill"),
        SwapItem(title: "Mike's Carrots", expirationDate: "2025-02-16", imageName: "leaf.fill")
    ]
    
    var body: some View {
        VStack {
            Text("List surplus food items and find neighbors to swap with.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.top)
            
            List(swapItems) { item in
                SwapItemRow(item: item)
            }
            .listStyle(PlainListStyle())
            
            // Optionally add a button to simulate adding a new listing
            Button("Add New Listing") {
                // Simulate the action to add a new listing
            }
            .padding()
        }
        .navigationTitle("Community Swap")
        .padding(.horizontal)
    }
}

struct CommunitySwapView_Previews: PreviewProvider {
    static var previews: some View {
        CommunitySwapView()
    }
}
