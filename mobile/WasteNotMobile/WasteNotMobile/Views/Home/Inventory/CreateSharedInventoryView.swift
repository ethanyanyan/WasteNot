//
//  Views/Home/Inventory/CreateSharedInventoryView.swift
//  WasteNotMobile
//
//  Created by Ethan Yan on 19/3/25.
//

import SwiftUI
import FirebaseAuth

struct CreateSharedInventoryView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var toastManager: ToastManager
    
    @State private var inventoryName: String = ""
    @State private var isCreating: Bool = false
    @State private var errorMessage: String?
    
    var onComplete: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("New Shared Inventory")) {
                    TextField("Inventory Name", text: $inventoryName)
                }
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Create Inventory")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    if isCreating {
                        ProgressView()
                    } else {
                        Button("Create") {
                            createInventory()
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func createInventory() {
        guard !inventoryName.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter a name."
            return
        }
        isCreating = true
        
        // Call the InventoryService to create a shared inventory.
        InventoryService.shared.createSharedInventory(name: inventoryName) { result in
            DispatchQueue.main.async {
                isCreating = false
                switch result {
                case .success(let newInventory):
                    toastManager.show(message: "Inventory created!", isSuccess: true)
                    presentationMode.wrappedValue.dismiss()
                    onComplete()
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    toastManager.show(message: error.localizedDescription, isSuccess: false)
                }
            }
        }
    }
}
