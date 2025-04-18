// SharedInventoryManager.swift
// WasteNotMobile
//
// Created by Ethan Yan on 12/4/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

struct SharedInventory: Identifiable, Hashable {
    let id: String
    let name: String
}

class SharedInventoryManager: ObservableObject {
    static let shared = SharedInventoryManager()
    
    @Published var sharedInventories: [SharedInventory] = []
    @Published var selectedInventory: SharedInventory? = nil
    @Published var isLoadingInventories: Bool = false   // ← new loading flag
    
    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        loadSharedInventories()
    }
    
    func loadSharedInventories() {
        guard let user = Auth.auth().currentUser else {
            DispatchQueue.main.async {
                self.sharedInventories = []
                self.isLoadingInventories = false
            }
            return
        }
        
        // indicate fetch in progress
        isLoadingInventories = true
        
        db.collection("inventories")
            .whereField("membersArray", arrayContains: user.uid)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching shared inventories: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.sharedInventories = []
                        self.isLoadingInventories = false
                    }
                }
                else if let snapshot = snapshot {
                    let inventories = snapshot.documents.compactMap { doc -> SharedInventory? in
                        let data = doc.data()
                        guard let name = data["name"] as? String else { return nil }
                        return SharedInventory(id: doc.documentID, name: name)
                    }
                    DispatchQueue.main.async {
                        self.sharedInventories = inventories
                        // default‐select first if none chosen
                        if !inventories.isEmpty, self.selectedInventory == nil {
                            self.selectInventory(inventories.first!)
                        }
                        self.isLoadingInventories = false
                    }
                }
            }
    }
    
    func selectInventory(_ inventory: SharedInventory) {
        self.selectedInventory = inventory
    }
    
    func refreshInventories() {
        loadSharedInventories()
    }
}
