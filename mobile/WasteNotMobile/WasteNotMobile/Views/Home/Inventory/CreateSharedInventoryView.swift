//
//  CreateSharedInventoryView.swift
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
    @State private var inviteEmail: String = ""
    @State private var invitedEmails: [String] = []   // Store added emails
    @State private var isCreating: Bool = false
    @State private var errorMessage: String?
    
    var onComplete: () -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                Form {
                    Section(header: Text("New Shared Inventory")) {
                        TextField("Inventory Name", text: $inventoryName)
                    }
                    
                    Section(header: Text("Invite Members (Optional)")) {
                        HStack {
                            TextField("Invite by email", text: $inviteEmail)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                            Button("Add") {
                                addEmail()
                            }
                        }
                        if !invitedEmails.isEmpty {
                            ForEach(invitedEmails, id: \.self) { email in
                                Text(email)
                                    .font(.caption)
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
    
    private func addEmail() {
        let email = inviteEmail.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !email.isEmpty else {
            errorMessage = "Email cannot be empty."
            return
        }
        // Simple email format validation.
        guard email.contains("@") && email.contains(".") else {
            errorMessage = "Please enter a valid email address."
            return
        }
        // Verify that a user document exists for the entered email.
        UserService().fetchUserProfileByEmail(email: email) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    if invitedEmails.contains(email) {
                        toastManager.show(message: "Email already added.", isSuccess: false)
                    } else {
                        invitedEmails.append(email)
                        toastManager.show(message: "Email added.", isSuccess: true)
                        inviteEmail = ""
                    }
                case .failure(let error):
                    toastManager.show(message: error.localizedDescription, isSuccess: false)
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
        
        InventoryService.shared.createSharedInventory(name: inventoryName) { result in
            DispatchQueue.main.async {
                isCreating = false
                switch result {
                case .success(let newInventory):
                    if !invitedEmails.isEmpty, let currentUID = Auth.auth().currentUser?.uid {
                        // For each invited email, send an invitation.
                        for email in invitedEmails {
                            UserService().fetchUserProfileByEmail(email: email) { profileResult in
                                DispatchQueue.main.async {
                                    switch profileResult {
                                    case .success(let profile):
                                        let invitedUID = profile.id
                                        NotificationsService.shared.checkExistingInvitation(to: invitedUID, forInventory: newInventory.id, from: currentUID) { exists in
                                            if exists {
                                                toastManager.show(message: "Invitation already sent to \(email).", isSuccess: false)
                                            } else {
                                                NotificationsService.shared.createInventoryInvitation(from: currentUID, to: invitedUID, inventoryId: newInventory.id, inventoryName: newInventory.name) { inviteResult in
                                                    DispatchQueue.main.async {
                                                        switch inviteResult {
                                                        case .success:
                                                            toastManager.show(message: "Invitation sent to \(email)!", isSuccess: true)
                                                        case .failure(let error):
                                                            toastManager.show(message: "Failed to send invitation to \(email): \(error.localizedDescription)", isSuccess: false)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    case .failure(let error):
                                        toastManager.show(message: "No user found with email \(email): \(error.localizedDescription)", isSuccess: false)
                                    }
                                }
                            }
                        }
                    } else {
                        toastManager.show(message: "Inventory created!", isSuccess: true)
                    }
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
