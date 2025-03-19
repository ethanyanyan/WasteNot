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

    // List of shared inventories the user belongs to.
    @State private var sharedInventories: [SharedInventory] = []
    // The currently selected shared inventory.
    @State private var selectedInventory: SharedInventory? = nil

    // State to control presentation of sheets.
    @State private var isShowingCreateInventory: Bool = false
    @State private var isShowingEditSharedInventory: Bool = false

    @EnvironmentObject var toastManager: ToastManager

    var body: some View {
        NavigationView {
            VStack {
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
                .onAppear {
                    loadInventories()
                }
                .alert(item: Binding(
                    get: { errorMessage == nil ? nil : InventoryError(message: errorMessage!) },
                    set: { _ in errorMessage = nil }
                )) { error in
                    Alert(title: Text("Error"), message: Text(error.message), dismissButton: .default(Text("OK")))
                }
                .sheet(item: $selectedItem, onDismiss: {
                    fetchItems()
                }) { item in
                    InventoryEditView(item: item, onSave: {
                        fetchItems()
                    })
                }
                .sheet(isPresented: $isAddingNewItem, onDismiss: {
                    fetchItems()
                }) {
                    InventoryAddView {
                        fetchItems()
                    }
                }
                .sheet(isPresented: $isShowingCreateInventory, onDismiss: {
                    loadInventories()
                }) {
                    CreateSharedInventoryView {
                        loadInventories()
                    }
                }
                .sheet(isPresented: $isShowingEditSharedInventory, onDismiss: {
                    loadInventories()
                }) {
                    EditSharedInventoryView(sharedInventory: selectedInventory ?? SharedInventory(id: "", name: ""), onComplete: {
                        loadInventories()
                    })
                }
                
                // Toast overlay.
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
            .toolbar {
                // Left side: Shared Inventory picker.
                ToolbarItem(placement: .navigationBarLeading) {
                    if !sharedInventories.isEmpty {
                        Menu {
                            ForEach(sharedInventories, id: \.self) { inventory in
                                Button(action: {
                                    self.selectedInventory = inventory
                                    InventoryService.shared.currentInventoryId = inventory.id
                                    fetchItems()
                                }) {
                                    Text(inventory.name)
                                }
                            }
                        } label: {
                            Text(selectedInventory?.name ?? "Shared Inventory")
                                .font(.headline)
                        }
                    } else {
                        Text("Shared Inventory")
                            .font(.headline)
                    }
                }
                // Right side: Edit, Add, New Inventory, and Refresh.
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button("Edit") {
                            isShowingEditSharedInventory = true
                        }
                        Button(action: {
                            isAddingNewItem = true
                        }) {
                            Image(systemName: "plus")
                        }
                        Button("New Inventory") {
                            isShowingCreateInventory = true
                        }
                        Button(action: {
                            fetchItems()
                        }) {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
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
    
    private func fetchItems() {
        InventoryService.shared.fetchInventoryItems { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let items):
                    self.inventoryItems = items
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func loadInventories() {
        InventoryService.shared.fetchSharedInventories { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let inventories):
                    self.sharedInventories = inventories
                    if self.selectedInventory == nil, let first = inventories.first {
                        self.selectedInventory = first
                        InventoryService.shared.currentInventoryId = first.id
                        fetchItems()
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
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
