//
//  Models/Inventory.swift
//  WasteNotMobile
//
//  Created by Ethan Yan on 26/2/25.
//

import Foundation
import FirebaseFirestore

struct InventoryItem: Identifiable {
    var id: String
    var barcode: String
    var itemName: String
    var quantity: Int
    var lastUpdated: Date
    var productDescription: String
    var imageURL: String
    var ingredients: String
    var nutritionFacts: String
    var brand: String
    var title: String
    var reminderDate: Date?
    var category: String
}

struct InventoryInvitation: Identifiable {
    var id: String
    var fromUser: String
    var toUser: String
    var inventoryId: String
    var inventoryName: String
    var status: String
    var createdAt: Date
}

struct InventoryError: Identifiable, Error {
    var id: String { message }
    var message: String
}
