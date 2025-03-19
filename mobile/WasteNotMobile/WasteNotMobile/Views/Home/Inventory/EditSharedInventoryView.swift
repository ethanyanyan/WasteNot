//
//  Views/Home/Inventory/EditSharedInventoryView.swift
//  WasteNotMobile
//
//  Created by Ethan Yan on 19/3/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct EditSharedInventoryView: View {
    var sharedInventory: SharedInventory
    var onComplete: () -> Void

    @State private var inventoryName: String = ""
    @State private var isSaving: Bool = false
    @State private var errorMessage: String?
    
    @EnvironmentObject var toastManager: ToastManager
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Inventory Details")) {
                    TextField("Inventory Name", text: $inventoryName)
                }
                Section(header: Text("Members")) {
                    // This is a placeholder; you can later add controls to add/remove members.
                    Text("Feature to add or remove members coming soon.")
                }
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Edit Inventory")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Button("Save") {
                            saveChanges()
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onAppear {
                inventoryName = sharedInventory.name
            }
        }
    }
    
    private func saveChanges() {
        guard !inventoryName.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Inventory name cannot be empty."
            return
        }
        isSaving = true
        InventoryService.shared.updateSharedInventoryName(inventoryId: sharedInventory.id, newName: inventoryName) { result in
            DispatchQueue.main.async {
                isSaving = false
                switch result {
                case .success:
                    toastManager.show(message: "Inventory updated!", isSuccess: true)
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
