//
//  Views/Home/Inventory/InventoryView.swift
//  WasteNotMobile
//
//  Created by Ethan Yan on 23/2/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct InventoryView: View {
    @State private var inventoryItems: [InventoryItem] = []
    @State private var errorMessage: String?
    @State private var selectedItem: InventoryItem?
    @State private var isAddingNewItem: Bool = false
    
    @EnvironmentObject var toastManager: ToastManager
    
    private let db = Firestore.firestore()
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ForEach(inventoryItems) { item in
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
                                if let reminder = item.reminderDate {
                                    Text("Reminder: \(reminder, formatter: itemDateFormatter)")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                                Text("Last Updated: \(item.lastUpdated, formatter: itemDateFormatter)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedItem = item
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                .navigationTitle("My Inventory")
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button {
                            fetchInventory()
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                        
                        Button {
                            isAddingNewItem = true
                        } label: {
                            Image(systemName: "plus")
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
                .sheet(item: $selectedItem, onDismiss: {
                    fetchInventory()
                }) { item in
                    InventoryEditView(item: item, onSave: {
                        fetchInventory()
                    })
                }
                .sheet(isPresented: $isAddingNewItem, onDismiss: {
                    fetchInventory()
                }) {
                    InventoryAddView {
                        fetchInventory()
                    }
                }
                
                // Toast overlay
                if toastManager.showToast {
                    VStack {
                        Spacer()
                        ToastView(message: toastManager.message, isSuccess: toastManager.isSuccess)
                            .padding(.bottom, 40)
                    }
                    .transition(.opacity)
                    .animation(.easeInOut, value: toastManager.showToast)
                }
            }
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        // Sort offsets descending to safely remove items from the array.
        for index in offsets.sorted(by: >) {
            let item = inventoryItems[index]
            InventoryService.shared.deleteInventoryItem(item: item) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        inventoryItems.remove(at: index)
                        toastManager.show(message: "Item deleted", isSuccess: true)
                    case .failure(let error):
                        toastManager.show(message: "Delete failed: \(error.localizedDescription)", isSuccess: false)
                    }
                }
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
                          let title = data["title"] as? String,
                          let category = data["category"] as? String else {
                        return nil
                    }
                    let reminderTimestamp: Timestamp?
                    if let ts = data["reminderDate"] as? Timestamp {
                        reminderTimestamp = ts
                    } else {
                        reminderTimestamp = nil
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
                        title: title,
                        reminderDate: reminderTimestamp?.dateValue(),
                        category: category
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
