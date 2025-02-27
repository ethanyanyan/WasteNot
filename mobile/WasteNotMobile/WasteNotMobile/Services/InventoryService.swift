//
//  Services/InventoryService.swift
//  cs8803
//
//  Created by Ethan Yan on 24/1/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class InventoryService {
    static let shared = InventoryService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    /// Updates an existing inventory item and schedules a reminder.
    func updateInventoryItem(updatedItem: InventoryItem,
                             completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "InventoryService", code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "User not logged in."])))
            return
        }
        
        let updatedData: [String: Any] = [
            "itemName": updatedItem.itemName,
            "quantity": updatedItem.quantity,
            "productDescription": updatedItem.productDescription,
            "lastUpdated": FieldValue.serverTimestamp(),
            "reminderDate": updatedItem.reminderDate ?? NSNull()
        ]
        
        db.collection("users").document(user.uid).collection("inventory").document(updatedItem.id)
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
    
    /// Adds a new inventory item with the given details and schedules a reminder.
    func addInventoryItem(newItem: InventoryItem,
                          completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "InventoryService", code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "User not logged in."])))
            return
        }
        
        // Prepare data dictionary.
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
            "reminderDate": newItem.reminderDate != nil ? Timestamp(date: newItem.reminderDate!) : NSNull()
        ]
        
        var ref: DocumentReference? = nil
        ref = db.collection("users").document(user.uid).collection("inventory").addDocument(data: newItemData) { error in
            if let error = error {
                completion(.failure(error))
            } else if let documentID = ref?.documentID {
                // Create a new InventoryItem with the document ID.
                var newItemWithID = newItem
                newItemWithID.id = documentID
                // Schedule a reminder for the new item.
                NotificationsService.shared.scheduleReminder(for: newItemWithID)
                completion(.success(()))
            } else {
                completion(.failure(NSError(domain: "InventoryService", code: -2,
                                            userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve document ID."])))
            }
        }
    }
    
    
    /// Delete Inventory Item
    func deleteInventoryItem(item: InventoryItem,
                             completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "InventoryService", code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "User not logged in."])))
            return
        }
        
        db.collection("users").document(user.uid).collection("inventory").document(item.id).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
