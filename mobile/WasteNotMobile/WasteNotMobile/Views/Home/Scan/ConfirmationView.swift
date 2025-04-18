//
//  ConfirmationView.swift
//  WasteNotMobile
//
//  Created by Ethan Yan on 23/2/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseRemoteConfig

extension Notification.Name {
    static let inventoryDidChange = Notification.Name("inventoryDidChange")
}

struct ConfirmationView: View {
    let scannedCode: String
    var onCompletion: () -> Void

    @EnvironmentObject var toastManager: ToastManager
    @ObservedObject var sharedInventoryManager = SharedInventoryManager.shared

    @State private var itemName: String = ""
    @State private var quantity: String = "1"
    @State private var updateStatus: String?
    @State private var productDescription: String = ""
    @State private var productImageURL: String = ""
    @State private var ingredients: String = ""
    @State private var nutritionFacts: String = ""
    @State private var productBrand: String = ""
    @State private var productTitle: String = ""
    @State private var category: String = "Dairy"
    @State private var categories: [String] = ["Dairy", "Vegetables", "Frozen", "Bakery", "Meat", "Other"]
    @State private var reminderDate: Date = Date()
    @State private var reminderService = ReminderDateService()
    
    // Remote Config for button text:
    @State private var confirmButtonText: String = "Confirm and Update Inventory"

    var body: some View {
        Form {
            Section(header: Text("Scanned Details")) {
                Text("Barcode: \(scannedCode)")
                TextField("Item Name", text: $itemName)
                    .onAppear { lookupProduct(for: scannedCode) }
                HStack {
                    Text("Quantity:")
                    TextField("Quantity", text: $quantity)
                        .keyboardType(.numberPad)
                }
            }

            Section(header: Text("Category & Reminder")) {
                Picker("Category", selection: $category) {
                    ForEach(categories, id: \.self) { cat in Text(cat) }
                }
                DatePicker("Reminder Date", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])
            }
            
            Section(header: Text("Save To Inventory")) {
                if sharedInventoryManager.sharedInventories.isEmpty {
                    Text("No shared inventories available.")
                        .font(.caption)
                        .foregroundColor(.gray)
                } else {
                    // disable selection while loading
                    Picker("Shared Inventory", selection: $sharedInventoryManager.selectedInventory) {
                        ForEach(sharedInventoryManager.sharedInventories, id: \.self) { inventory in
                            Text(inventory.name).tag(inventory as SharedInventory?)
                        }
                    }
                    .disabled(sharedInventoryManager.isLoadingInventories)
                }
            }

            Section {
                Button(confirmButtonText) {
                    updateInventory()
                }
                // ← disabled until inventories have loaded and one is selected
                .disabled(sharedInventoryManager.isLoadingInventories
                          || sharedInventoryManager.selectedInventory == nil)
            }

            Section {
                Button("Cancel") {
                    onCompletion()
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("Confirm Scan")
        .onAppear {
            // load inventories & defaults
            sharedInventoryManager.refreshInventories()
            reminderService.fetchMapping {
                let rawDefault = reminderService.defaultReminderDate(for: category)
                let lead = Int(UserSettingsManager.shared.defaultNotificationLeadTime * 3600)
                reminderDate = Calendar.current.date(byAdding: .second, value: -lead, to: rawDefault) ?? rawDefault
            }
            // Remote Config
            let rc = RemoteConfig.remoteConfig()
            rc.setDefaults(["confirm_button_text": "Confirm and Update Inventory" as NSObject])
            rc.fetch(withExpirationDuration: 3600) { status, error in
                if status == .success {
                    rc.activate { _, _ in
                        DispatchQueue.main.async {
                            confirmButtonText = rc["confirm_button_text"].stringValue ?? confirmButtonText
                        }
                    }
                }
            }
        }
    }

    private func updateInventory() {
        guard let qty = Int(quantity) else {
            toastManager.show(message: "Invalid quantity.", isSuccess: false)
            return
        }
        guard let inventoryId = sharedInventoryManager.selectedInventory?.id else {
            toastManager.show(message: "No inventory selected.", isSuccess: false)
            return
        }
        
        let currentUid = Auth.auth().currentUser?.uid ?? "Unknown"
        let newItem = InventoryItem(
            id: "",
            barcode: scannedCode,
            itemName: itemName,
            quantity: qty,
            lastUpdated: Date(),
            productDescription: productDescription,
            imageURL: productImageURL,
            ingredients: ingredients,
            nutritionFacts: nutritionFacts,
            brand: productBrand,
            title: productTitle,
            reminderDate: reminderDate,
            category: category,
            createdBy: currentUid,
            lastUpdatedBy: currentUid
        )
        
        print("📦 ConfirmationView: adding '\(newItem.itemName)' to inventory \(inventoryId)")
        InventoryService.shared.addInventoryItem(newItem: newItem,
                                                 toInventoryId: inventoryId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // tell InventoryView to refresh:
                    NotificationCenter.default.post(name: .inventoryDidChange, object: nil)
                    
                    toastManager.show(message: "Item added successfully!", isSuccess: true)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.easeInOut(duration: 0.3)) { onCompletion() }
                    }
                case .failure(let error):
                    toastManager.show(message: "Error: \(error.localizedDescription)", isSuccess: false)
                }
            }
        }
    }

    private func lookupProduct(for barcode: String) {
        guard let url = URL(string: "https://world.openfoodfacts.org/api/v3/product/\(barcode).json") else {
            print("Invalid URL for Open Food Facts lookup")
            DispatchQueue.main.async {
                self.itemName = "Item: \(barcode)"
            }
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Open Food Facts lookup error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.itemName = "Item: \(barcode)"
                }
                return
            }

            guard let data = data else {
                print("No data received from Open Food Facts")
                DispatchQueue.main.async {
                    self.itemName = "Item: \(barcode)"
                }
                return
            }

            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let product = jsonResponse["product"] as? [String: Any] {
                    let name = product["product_name"] as? String ?? ""
                    let brand = product["brands"] as? String ?? ""
                    let defaultName = brand.isEmpty ? name : (!name.isEmpty ? "\(brand) \(name)" : brand)
                    let genericName = product["generic_name"] as? String ?? ""
                    let ingredientsText = product["ingredients_text"] as? String ?? ""
                    let imageUrl = product["image_url"] as? String ?? ""

                    let scannedCategories = product["categories"] as? String ?? ""
                    let newCategory = scannedCategories.components(separatedBy: ",").first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Other"
                    if !self.categories.contains(newCategory) {
                        self.categories.append(newCategory)
                    }

                    DispatchQueue.main.async {
                        self.itemName = defaultName.isEmpty ? "Item: \(barcode)" : defaultName
                        self.productBrand = brand
                        self.productTitle = name
                        self.productDescription = genericName
                        self.ingredients = ingredientsText
                        self.nutritionFacts = ""
                        self.productImageURL = imageUrl
                        self.category = newCategory

                        let rawDefault = self.reminderService.defaultReminderDate(for: newCategory)
                        let globalLeadTime = UserSettingsManager.shared.defaultNotificationLeadTime
                        let leadTimeInSeconds = Int(globalLeadTime * 3600)
                        self.reminderDate = Calendar.current.date(byAdding: .second, value: -leadTimeInSeconds, to: rawDefault) ?? rawDefault
                    }
                } else {
                    DispatchQueue.main.async {
                        self.itemName = "Item: \(barcode)"
                    }
                }
            } catch {
                print("Error parsing Open Food Facts response: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.itemName = "Item: \(barcode)"
                }
            }
        }
        task.resume()
    }
}
