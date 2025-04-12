//
//  Managers/SharedInventoryManager.swift
//  WasteNotMobile
//
//  Created by Ethan Yan on 12/4/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class SharedInventoryManager: ObservableObject {
    static let shared = SharedInventoryManager()
    
    @Published var sharedInventories: [SharedInventory] = []
    @Published var selectedInventory: SharedInventory? = nil
    
    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        loadSharedInventories()
    }
    
    func loadSharedInventories() {
        guard let user = Auth.auth().currentUser else {
            self.sharedInventories = []
            return
        }
        
        db.collection("inventories")
            .whereField("membersArray", arrayContains: user.uid)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching shared inventories: \(error.localizedDescription)")
                } else if let snapshot = snapshot {
                    let inventories = snapshot.documents.compactMap { doc -> SharedInventory? in
                        let data = doc.data()
                        guard let name = data["name"] as? String else { return nil }
                        return SharedInventory(id: doc.documentID, name: name)
                    }
                    DispatchQueue.main.async {
                        self.sharedInventories = inventories
                        if self.selectedInventory == nil, let firstInventory = inventories.first {
                            self.selectInventory(firstInventory)
                        }
                    }
                }
            }
    }
    
    func selectInventory(_ inventory: SharedInventory) {
        self.selectedInventory = inventory
        // Update the InventoryService global variable to use this shared inventory.
        InventoryService.shared.currentInventoryId = inventory.id
    }
    
    func refreshInventories() {
        loadSharedInventories()
    }
}
