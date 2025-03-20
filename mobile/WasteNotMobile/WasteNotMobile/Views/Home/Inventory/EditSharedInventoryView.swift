//
//  EditSharedInventoryView.swift
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
    
    // We store an array of (uid, username)
    @State private var members: [(uid: String, username: String)] = []
    @State private var newMemberEmail: String = ""
    
    @EnvironmentObject var toastManager: ToastManager
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ZStack {
                Form {
                    Section(header: Text("Inventory Details")) {
                        TextField("Inventory Name", text: $inventoryName)
                    }
                    
                    Section(header: Text("Members")) {
                        if members.isEmpty {
                            Text("No members yet.")
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(members, id: \.uid) { member in
                                Text(member.username)
                                    .font(.caption)
                            }
                        }
                        
                        HStack {
                            TextField("Invite by email", text: $newMemberEmail)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                            Button("Invite") {
                                inviteMember()
                            }
                        }
                    }
                    
                    if let errorMessage = errorMessage {
                        Section {
                            Text(errorMessage)
                                .foregroundColor(.red)
                        }
                    }
                }
                if toastManager.showToast {
                    ToastView(message: toastManager.message, isSuccess: toastManager.isSuccess)
                        .zIndex(1)
                        .transition(.opacity)
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
                loadMembers()
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
    
    private func loadMembers() {
        InventoryService.shared.fetchSharedInventoryMembers(inventoryId: sharedInventory.id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let uids):
                    self.members = []
                    for uid in uids {
                        UserService().fetchUserProfile(uid: uid) { profileResult in
                            DispatchQueue.main.async {
                                switch profileResult {
                                case .success(let profile):
                                    if !self.members.contains(where: { $0.uid == profile.id }) {
                                        self.members.append((uid: profile.id, username: profile.username))
                                    }
                                case .failure(let error):
                                    print("Error fetching profile for \(uid): \(error.localizedDescription)")
                                }
                            }
                        }
                    }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func inviteMember() {
        guard !newMemberEmail.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter an email address."
            return
        }
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        
        UserService().fetchUserProfileByEmail(email: newMemberEmail) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    let invitedUID = profile.id
                    NotificationsService.shared.checkExistingInvitation(to: invitedUID, forInventory: sharedInventory.id, from: currentUID) { exists in
                        if exists {
                            toastManager.show(message: "Invitation already sent.", isSuccess: false)
                        } else {
                            NotificationsService.shared.createInventoryInvitation(from: currentUID, to: invitedUID, inventoryId: sharedInventory.id, inventoryName: sharedInventory.name) { result in
                                DispatchQueue.main.async {
                                    switch result {
                                    case .success:
                                        toastManager.show(message: "Invitation sent!", isSuccess: true)
                                        newMemberEmail = ""
                                    case .failure(let error):
                                        errorMessage = error.localizedDescription
                                        toastManager.show(message: error.localizedDescription, isSuccess: false)
                                    }
                                }
                            }
                        }
                    }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    toastManager.show(message: error.localizedDescription, isSuccess: false)
                }
            }
        }
    }
}
