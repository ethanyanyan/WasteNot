//
//  SharedInventoryManager.swift
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
                        if !inventories.isEmpty, self.selectedInventory == nil {
                            // If no inventory is currently selected, default to the first one.
                            self.selectInventory(inventories.first!)
                        }
                    }
                }
            }
    }
    
    func selectInventory(_ inventory: SharedInventory) {
        self.selectedInventory = inventory
        // The updated InventoryService now reads directly from SharedInventoryManager.shared.selectedInventory,
        // so there is no need to update a separate global variable here.
    }
    
    func refreshInventories() {
        loadSharedInventories()
    }
}
