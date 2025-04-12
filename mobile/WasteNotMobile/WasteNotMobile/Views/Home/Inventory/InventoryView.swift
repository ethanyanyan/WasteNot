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

    // Use the SharedInventoryManager for shared inventories.
    @ObservedObject private var sharedInventoryManager = SharedInventoryManager.shared

    // New state variable for pending notification count.
    @State private var notificationCount: Int = 0

    // State to control presentation of sheets.
    @State private var isShowingCreateInventory: Bool = false
    @State private var isShowingEditSharedInventory: Bool = false
    @State private var isShowingNotifications: Bool = false

    @EnvironmentObject var toastManager: ToastManager

    // Cache fetched usernames for uids.
    @State private var userNames: [String: String] = [:]

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
                                Text("Last Updated: \(item.lastUpdated, formatter: itemDateFormatter) (by \(userNames[item.lastUpdatedBy] ?? "Unknown"))")
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
                    // Refresh shared inventories.
                    sharedInventoryManager.refreshInventories()
                    fetchNotificationCount()
                    // Do not call fetchItems() immediately.
                    // Observe invitation acceptance notifications.
                    NotificationCenter.default.addObserver(forName: NSNotification.Name("InvitationAccepted"), object: nil, queue: .main) { _ in
                        sharedInventoryManager.refreshInventories()
                        fetchItems()
                    }
                }
                // Call fetchItems() when a shared inventory is selected.
                .onReceive(sharedInventoryManager.$selectedInventory) { selected in
                    if selected != nil {
                        fetchItems()
                    }
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
                    sharedInventoryManager.refreshInventories()
                }) {
                    CreateSharedInventoryView {
                        sharedInventoryManager.refreshInventories()
                    }
                }
                .sheet(isPresented: $isShowingEditSharedInventory, onDismiss: {
                    sharedInventoryManager.refreshInventories()
                }) {
                    EditSharedInventoryView(sharedInventory: sharedInventoryManager.selectedInventory ?? SharedInventory(id: "", name: ""), onComplete: {
                        sharedInventoryManager.refreshInventories()
                    })
                }
                .sheet(isPresented: $isShowingNotifications, onDismiss: {
                    fetchNotificationCount()
                }) {
                    NotificationsView()
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
                // Leading: Shared Inventory Picker using SharedInventoryManager.
                ToolbarItem(placement: .navigationBarLeading) {
                    if !sharedInventoryManager.sharedInventories.isEmpty {
                        Menu {
                            ForEach(sharedInventoryManager.sharedInventories, id: \.self) { inventory in
                                Button(action: {
                                    sharedInventoryManager.selectInventory(inventory)
                                    fetchItems()
                                }) {
                                    Text(inventory.name)
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "folder")
                                Text(sharedInventoryManager.selectedInventory?.name ?? "Shared Inventory")
                                    .font(.headline)
                            }
                        }
                    } else {
                        Text("Shared Inventory")
                            .font(.headline)
                    }
                }
                // Trailing: Add New Item button, notifications button (with badge), and a grouped Manage menu.
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        isAddingNewItem = true
                    }) {
                        Image(systemName: "plus")
                    }
                    
                    Button(action: {
                        isShowingNotifications = true
                    }) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: notificationCount > 0 ? "bell.fill" : "bell")
                            if notificationCount > 0 {
                                Text("\(notificationCount)")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                                    .padding(4)
                                    .background(Circle().fill(Color.red))
                                    .offset(x: 10, y: -10)
                            }
                        }
                    }
                    
                    Menu {
                        Button("Edit Inventory") {
                            isShowingEditSharedInventory = true
                        }
                        Button("New Inventory") {
                            isShowingCreateInventory = true
                        }
                        Button("Refresh") {
                            fetchItems()
                            sharedInventoryManager.refreshInventories()
                            fetchNotificationCount()
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .imageScale(.large)
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
        // Check that a shared inventory is selected
        guard let _ = InventoryService.shared.currentInventoryId else {
            print("No shared inventory selected. Will retry fetching items after delay.")
            // Delay and then try again
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                fetchItems()
            }
            return
        }
        
        InventoryService.shared.fetchInventoryItems { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let items):
                    self.inventoryItems = items
                    // For each distinct lastUpdatedBy uid, fetch the username if not already cached.
                    let uids = Set(items.map { $0.lastUpdatedBy })
                    for uid in uids {
                        if self.userNames[uid] == nil {
                            UserService().fetchUserProfile(uid: uid) { result in
                                DispatchQueue.main.async {
                                    switch result {
                                    case .success(let profile):
                                        self.userNames[uid] = profile.username
                                    case .failure(_):
                                        self.userNames[uid] = "Unknown"
                                    }
                                }
                            }
                        }
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func fetchNotificationCount() {
        NotificationsService.shared.fetchPendingInvitations { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let invitations):
                    self.notificationCount = invitations.count
                    print("Notification count: \(self.notificationCount)")
                case .failure(let error):
                    print("Error fetching notifications: \(error.localizedDescription)")
                }
            }
        }
    }
}

private let itemDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()
