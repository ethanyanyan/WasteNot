//
//  InventoryView.swift
//  WasteNotMobile
//
//  Created by Ethan Yan on 23/2/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct InventoryItem: Identifiable {
    var id: String
    var barcode: String
    var itemName: String
    var quantity: Int
    var lastUpdated: Date
    var productDescription: String
    var imageURL: String
    var ingredients: String
    var nutritionFacts: String
    var brand: String
    var title: String
}

struct InventoryView: View {
    @State private var inventoryItems: [InventoryItem] = []
    @State private var errorMessage: String?
    
    // Firestore reference
    private let db = Firestore.firestore()
    
    var body: some View {
        NavigationView {
            List(inventoryItems) { item in
                HStack {
                    if let url = URL(string: item.imageURL), !item.imageURL.isEmpty {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 50, height: 50)
                            case .success(let image):
                                image.resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 50, height: 50)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            case .failure(_):
                                Image(systemName: "photo")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text(item.itemName)
                            .font(.headline)
                        Text("Quantity: \(item.quantity)")
                            .font(.subheadline)
                        Text("Last Updated: \(item.lastUpdated, formatter: itemDateFormatter)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("My Inventory")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Refresh") {
                        fetchInventory()
                    }
                }
            }
            .onAppear {
                fetchInventory()
            }
            .alert(item: Binding(
                get: { errorMessage == nil ? nil : InventoryError(message: errorMessage!) },
                set: { _ in errorMessage = nil }
            )) { error in
                Alert(title: Text("Error"), message: Text(error.message), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func fetchInventory() {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "User not logged in."
            return
        }
        
        db.collection("users").document(user.uid).collection("inventory").getDocuments { snapshot, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else if let snapshot = snapshot {
                let items = snapshot.documents.compactMap { doc -> InventoryItem? in
                    let data = doc.data()
                    guard let barcode = data["barcode"] as? String,
                          let itemName = data["itemName"] as? String,
                          let quantity = data["quantity"] as? Int,
                          let timestamp = data["lastUpdated"] as? Timestamp,
                          let productDescription = data["productDescription"] as? String,
                          let imageURL = data["imageURL"] as? String,
                          let ingredients = data["ingredients"] as? String,
                          let nutritionFacts = data["nutritionFacts"] as? String,
                          let brand = data["brand"] as? String,
                          let title = data["title"] as? String else {
                        return nil
                    }
                    
                    return InventoryItem(
                        id: doc.documentID,
                        barcode: barcode,
                        itemName: itemName,
                        quantity: quantity,
                        lastUpdated: timestamp.dateValue(),
                        productDescription: productDescription,
                        imageURL: imageURL,
                        ingredients: ingredients,
                        nutritionFacts: nutritionFacts,
                        brand: brand,
                        title: title
                    )
                }
                DispatchQueue.main.async {
                    self.inventoryItems = items
                }
            }
        }
    }
}

private struct InventoryError: Identifiable {
    var id: String { message }
    let message: String
}

private let itemDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()
