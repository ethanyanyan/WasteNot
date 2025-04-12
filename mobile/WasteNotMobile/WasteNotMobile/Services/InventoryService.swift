//
//  Services/InventoryService.swift
//  cs8803
//
//  Created by Ethan Yan on 24/1/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

// Model to represent a shared inventory.
struct SharedInventory: Identifiable, Hashable {
    let id: String
    let name: String
}

class InventoryService {
    static let shared = InventoryService()
    private let db = Firestore.firestore()
    
    // The currently selected shared inventory's document ID.
    var currentInventoryId: String?
    
    private init() {}
    
    // MARK: - Inventory Item CRUD Operations
    
    /// Updates an existing inventory item and schedules a reminder.
    func updateInventoryItem(updatedItem: InventoryItem,
                             completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "InventoryService", code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "User not logged in."])))
            return
        }
        guard let inventoryId = currentInventoryId else {
            completion(.failure(NSError(domain: "InventoryService", code: -3,
                                        userInfo: [NSLocalizedDescriptionKey: "No shared inventory selected."])))
            return
        }
        
        let updatedData: [String: Any] = [
            "itemName": updatedItem.itemName,
            "quantity": updatedItem.quantity,
            "productDescription": updatedItem.productDescription,
            "lastUpdated": FieldValue.serverTimestamp(),
            "lastUpdatedBy": currentUser.uid,
            "reminderDate": updatedItem.reminderDate ?? NSNull()
        ]
        
        db.collection("inventories")
            .document(inventoryId)
            .collection("items")
            .document(updatedItem.id)
            .updateData(updatedData) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    // Schedule the updated reminder.
                    NotificationsService.shared.scheduleReminder(for: updatedItem)
                    completion(.success(()))
                }
            }
    }
    
    /// Adds a new inventory item and schedules a reminder.
    func addInventoryItem(newItem: InventoryItem,
                          completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "InventoryService", code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "User not logged in."])))
            return
        }
        guard let inventoryId = currentInventoryId else {
            completion(.failure(NSError(domain: "InventoryService", code: -3,
                                        userInfo: [NSLocalizedDescriptionKey: "No shared inventory selected."])))
            return
        }
        
        let newItemData: [String: Any] = [
            "barcode": newItem.barcode,
            "itemName": newItem.itemName,
            "quantity": newItem.quantity,
            "lastUpdated": FieldValue.serverTimestamp(),
            "productDescription": newItem.productDescription,
            "imageURL": newItem.imageURL,
            "ingredients": newItem.ingredients,
            "nutritionFacts": newItem.nutritionFacts,
            "brand": newItem.brand,
            "title": newItem.title,
            "category": newItem.category,
            "reminderDate": newItem.reminderDate != nil ? Timestamp(date: newItem.reminderDate!) : NSNull(),
            "createdBy": currentUser.uid,
            "lastUpdatedBy": currentUser.uid
        ]
        
        var ref: DocumentReference? = nil
        ref = db.collection("inventories")
            .document(inventoryId)
            .collection("items")
            .addDocument(data: newItemData) { error in
                if let error = error {
                    completion(.failure(error))
                } else if let documentID = ref?.documentID {
                    var newItemWithID = newItem
                    newItemWithID.id = documentID
                    NotificationsService.shared.scheduleReminder(for: newItemWithID)
                    completion(.success(()))
                } else {
                    completion(.failure(NSError(domain: "InventoryService", code: -2,
                                                userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve document ID."])))
                }
            }
    }
    
    /// Deletes an inventory item.
    func deleteInventoryItem(item: InventoryItem,
                             completion: @escaping (Result<Void, Error>) -> Void) {
        guard Auth.auth().currentUser != nil else {
            completion(.failure(NSError(domain: "InventoryService", code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "User not logged in."])))
            return
        }
        guard let inventoryId = currentInventoryId else {
            completion(.failure(NSError(domain: "InventoryService", code: -3,
                                        userInfo: [NSLocalizedDescriptionKey: "No shared inventory selected."])))
            return
        }
        
        db.collection("inventories")
            .document(inventoryId)
            .collection("items")
            .document(item.id)
            .delete { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }
    
    // MARK: - Fetching Data
    
    /// Fetches inventory items from the currently selected inventory.
    func fetchInventoryItems(completion: @escaping (Result<[InventoryItem], Error>) -> Void) {
        guard let inventoryId = currentInventoryId else {
            completion(.failure(NSError(domain: "InventoryService", code: -3,
                                        userInfo: [NSLocalizedDescriptionKey: "No shared inventory selected."])))
            return
        }
        
        db.collection("inventories")
            .document(inventoryId)
            .collection("items")
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else if let snapshot = snapshot {
                    let items = snapshot.documents.compactMap { doc -> InventoryItem? in
                        let data = doc.data()
                        guard let barcode = data["barcode"] as? String,
                              let itemName = data["itemName"] as? String,
                              let quantity = data["quantity"] as? Int,
                              let timestamp = data["lastUpdated"] as? Timestamp,
                              let productDescription = data["productDescription"] as? String,
                              let imageURL = data["imageURL"] as? String,
                              let ingredients = data["ingredients"] as? String,
                              let nutritionFacts = data["nutritionFacts"] as? String,
                              let brand = data["brand"] as? String,
                              let title = data["title"] as? String,
                              let category = data["category"] as? String else {
                            return nil
                        }
                        let reminderTimestamp: Timestamp?
                        if let ts = data["reminderDate"] as? Timestamp {
                            reminderTimestamp = ts
                        } else {
                            reminderTimestamp = nil
                        }
                        
                        return InventoryItem(
                            id: doc.documentID,
                            barcode: barcode,
                            itemName: itemName,
                            quantity: quantity,
                            lastUpdated: timestamp.dateValue(),
                            productDescription: productDescription,
                            imageURL: imageURL,
                            ingredients: ingredients,
                            nutritionFacts: nutritionFacts,
                            brand: brand,
                            title: title,
                            reminderDate: reminderTimestamp?.dateValue(),
                            category: category,
                            createdBy: data["createdBy"] as? String ?? "Unknown",
                            lastUpdatedBy: data["lastUpdatedBy"] as? String ?? "Unknown"
                        )
                    }
                    completion(.success(items))
                }
            }
    }
    
    /// Fetches shared inventories that the current user is a member of.
    func fetchSharedInventories(completion: @escaping (Result<[SharedInventory], Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "InventoryService", code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "User not logged in."])))
            return
        }
        
        // Here we assume each inventory document includes a "membersArray" field with UIDs.
        db.collection("inventories")
            .whereField("membersArray", arrayContains: user.uid)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else if let snapshot = snapshot {
                    let inventories = snapshot.documents.compactMap { doc -> SharedInventory? in
                        let data = doc.data()
                        guard let name = data["name"] as? String else { return nil }
                        return SharedInventory(id: doc.documentID, name: name)
                    }
                    completion(.success(inventories))
                }
            }
    }
    
    // MARK: - Create Shared Inventory
    /// Creates a new shared inventory document.
    func createSharedInventory(name: String, completion: @escaping (Result<SharedInventory, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "InventoryService", code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "User not logged in."])))
            return
        }
        
        // Create the shared inventory document with the current user as the owner.
        let inventoryData: [String: Any] = [
            "name": name,
            "owner": user.uid,
            // You can initialize the members map with the owner, e.g.:
            "members": [user.uid: "owner"],
            // Also include a membersArray field for query convenience.
            "membersArray": [user.uid],
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        var ref: DocumentReference? = nil
        ref = db.collection("inventories").addDocument(data: inventoryData) { error in
            if let error = error {
                completion(.failure(error))
            } else if let documentID = ref?.documentID {
                let newInventory = SharedInventory(id: documentID, name: name)
                completion(.success(newInventory))
            } else {
                completion(.failure(NSError(domain: "InventoryService", code: -2,
                                            userInfo: [NSLocalizedDescriptionKey: "Failed to create inventory."])))
            }
        }
    }
    
    /// Updates the name of a shared inventory.
    func updateSharedInventoryName(inventoryId: String, newName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("inventories").document(inventoryId).updateData(["name": newName]) { error in
             if let error = error {
                 completion(.failure(error))
             } else {
                 completion(.success(()))
             }
        }
    }
    
    // MARK: - Shared Inventory Members Management

    /// Fetches member UIDs of a shared inventory.
    func fetchSharedInventoryMembers(inventoryId: String, completion: @escaping (Result<[String], Error>) -> Void) {
        db.collection("inventories").document(inventoryId).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else if let snapshot = snapshot, snapshot.exists {
                let data = snapshot.data() ?? [:]
                if let members = data["members"] as? [String: String] {
                    let uids = Array(members.keys)
                    completion(.success(uids))
                } else {
                    completion(.success([]))
                }
            } else {
                completion(.failure(NSError(domain: "InventoryService", code: -5, userInfo: [NSLocalizedDescriptionKey: "Inventory not found."])))
            }
        }
    }

    /// Adds a member to a shared inventory using their email address.
    /// It looks up the user document in the "users" collection by email, then updates the inventory’s "members" map and "membersArray".
    func addMemberToSharedInventory(inventoryId: String, memberEmail: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("users")
          .whereField("email", isEqualTo: memberEmail)
          .getDocuments { snapshot, error in
              if let error = error {
                  completion(.failure(error))
                  return
              }
              guard let doc = snapshot?.documents.first else {
                  completion(.failure(NSError(domain: "InventoryService", code: -4,
                                              userInfo: [NSLocalizedDescriptionKey: "No user found with that email."])))
                  return
              }
              let memberUid = doc.documentID
              let updateData: [String: Any] = [
                  "members.\(memberUid)": "member",
                  "membersArray": FieldValue.arrayUnion([memberUid])
              ]
              self.db.collection("inventories").document(inventoryId).updateData(updateData) { error in
                  if let error = error {
                      completion(.failure(error))
                  } else {
                      completion(.success(()))
                  }
              }
          }
    }
    
    func fetchInventoryName(for inventoryId: String, completion: @escaping (Result<String, Error>) -> Void) {
        db.collection("inventories").document(inventoryId).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else if let snapshot = snapshot, snapshot.exists, let data = snapshot.data(), let name = data["name"] as? String {
                completion(.success(name))
            } else {
                completion(.failure(NSError(domain: "InventoryService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Inventory not found."])))
            }
        }
    }

}
