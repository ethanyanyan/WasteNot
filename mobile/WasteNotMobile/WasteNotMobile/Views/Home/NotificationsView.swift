import SwiftUI
import FirebaseAuth

struct NotificationsView: View {
    @State private var invitations: [InventoryInvitation] = []
    @State private var errorMessage: String?
    
    @EnvironmentObject var toastManager: ToastManager
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ZStack {
                List {
                    if invitations.isEmpty {
                        Text("No pending invitations.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(invitations) { invitation in
                            InvitationRow(invitation: invitation, onAction: {
                                loadInvitations()
                            })
                        }
                    }
                }
                if toastManager.showToast {
                    ToastView(message: toastManager.message, isSuccess: toastManager.isSuccess)
                        .zIndex(1)
                        .transition(.opacity)
                }
            }
            .navigationTitle("Invitations")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onAppear {
                loadInvitations()
            }
            .alert(item: Binding(
                get: { errorMessage == nil ? nil : InventoryError(message: errorMessage!) },
                set: { _ in errorMessage = nil }
            )) { error in
                Alert(title: Text("Error"), message: Text(error.message), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func loadInvitations() {
        NotificationsService.shared.fetchPendingInvitations { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let invs):
                    self.invitations = invs
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}


struct InvitationRow: View {
    let invitation: InventoryInvitation
    var onAction: () -> Void

    @State private var inviterName: String = ""
    @State private var isProcessing: Bool = false
    @State private var errorMessage: String?
    
    @EnvironmentObject var toastManager: ToastManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("From: \(inviterName)")
                    .font(.headline)
                Spacer()
                if isProcessing {
                    ProgressView()
                }
            }
            Text("Invited to join: \(invitation.inventoryName)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            HStack {
                Button("Accept") {
                    acceptInvitation()
                }
                .foregroundColor(.green)
                Spacer()
                Button("Decline") {
                    declineInvitation()
                }
                .foregroundColor(.red)
            }
        }
        .padding(.vertical, 4)
        .onAppear {
            loadInviterName()
        }
    }
    
    private func loadInviterName() {
        UserService().fetchUserProfile(uid: invitation.fromUser) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    inviterName = profile.username
                case .failure:
                    inviterName = "Unknown"
                }
            }
        }
    }
    
    private func acceptInvitation() {
        isProcessing = true
        NotificationsService.shared.acceptInventoryInvitation(invitation) { result in
            DispatchQueue.main.async {
                isProcessing = false
                switch result {
                case .success:
                    // Show toast and dismiss the notifications sheet.
                    toastManager.show(message: "Invitation accepted!", isSuccess: true)
                    // Dismiss the NotificationsView sheet.
                    presentationMode.wrappedValue.dismiss()
                    // Post a notification so that InventoryView refreshes.
                    NotificationCenter.default.post(name: NSNotification.Name("InvitationAccepted"), object: nil)
                    onAction()
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    toastManager.show(message: error.localizedDescription, isSuccess: false)
                }
            }
        }
    }
    
    private func declineInvitation() {
        isProcessing = true
        NotificationsService.shared.declineInventoryInvitation(invitation) { result in
            DispatchQueue.main.async {
                isProcessing = false
                switch result {
                case .success:
                    toastManager.show(message: "Invitation declined.", isSuccess: true)
                    presentationMode.wrappedValue.dismiss()
                    NotificationCenter.default.post(name: NSNotification.Name("InvitationAccepted"), object: nil)
                    onAction()
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    toastManager.show(message: error.localizedDescription, isSuccess: false)
                }
            }
        }
    }
}
