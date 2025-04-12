//
//  Views/Home/Scan/ConfirmationView.swift
//  WasteNotMobile
//
//  Created by Ethan Yan on 23/2/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ConfirmationView: View {
    let scannedCode: String
    var onCompletion: () -> Void   // Called when confirmation is done or cancelled

    @EnvironmentObject var toastManager: ToastManager
    @ObservedObject var sharedInventoryManager = SharedInventoryManager.shared

    @State private var itemName: String = ""
    @State private var quantity: String = "1"
    @State private var updateStatus: String?

    // Additional product information
    @State private var productDescription: String = ""
    @State private var productImageURL: String = ""
    @State private var ingredients: String = ""
    @State private var nutritionFacts: String = ""
    @State private var productBrand: String = ""
    @State private var productTitle: String = ""

    // Category & reminder date (as set by user)
    @State private var category: String = "Dairy"
    @State private var categories: [String] = ["Dairy", "Vegetables", "Frozen", "Bakery", "Meat", "Other"]
    @State private var reminderDate: Date = Date()
    @State private var reminderService = ReminderDateService()

    var body: some View {
        Form {
            Section(header: Text("Scanned Details")) {
                Text("Barcode: \(scannedCode)")
                TextField("Item Name", text: $itemName)
                    .onAppear {
                        lookupProduct(for: scannedCode)
                    }
                HStack {
                    Text("Quantity:")
                    TextField("Quantity", text: $quantity)
                        .keyboardType(.numberPad)
                }
            }

            Section(header: Text("Category & Reminder")) {
                Picker("Category", selection: $category) {
                    ForEach(categories, id: \.self) { cat in
                        Text(cat)
                    }
                }
                // The DatePicker now shows the effective reminder date.
                DatePicker("Reminder Date", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])
            }
            
            // Picker for shared inventory selection.
            Section(header: Text("Save To Inventory")) {
                if sharedInventoryManager.sharedInventories.isEmpty {
                    Text("No shared inventories available.")
                        .font(.caption)
                        .foregroundColor(.gray)
                } else {
                    Picker("Shared Inventory", selection: $sharedInventoryManager.selectedInventory) {
                        ForEach(sharedInventoryManager.sharedInventories, id: \.self) { inventory in
                            Text(inventory.name).tag(inventory as SharedInventory?)
                        }
                    }
                    .onChange(of: sharedInventoryManager.selectedInventory) { newValue in
                        if let selected = newValue {
                            sharedInventoryManager.selectInventory(selected)
                        }
                    }
                }
            }

            Section {
                Button("Confirm and Update Inventory") {
                    updateInventory()
                }
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
            // Fetch default raw reminder date based on category
            reminderService.fetchMapping {
                let rawDefault = reminderService.defaultReminderDate(for: category)
                let globalLeadTime = UserSettingsManager.shared.defaultNotificationLeadTime
                let leadTimeInSeconds = Int(globalLeadTime * 3600)
                reminderDate = Calendar.current.date(byAdding: .second, value: -leadTimeInSeconds, to: rawDefault) ?? rawDefault
            }
            // Also ensure shared inventories are refreshed.
            sharedInventoryManager.refreshInventories()
        }
        .onChange(of: category) { newValue in
            // Update reminder date when category changes
            let rawDefault = reminderService.defaultReminderDate(for: newValue)
            let globalLeadTime = UserSettingsManager.shared.defaultNotificationLeadTime
            let leadTimeInSeconds = Int(globalLeadTime * 3600)
            reminderDate = Calendar.current.date(byAdding: .second, value: -leadTimeInSeconds, to: rawDefault) ?? rawDefault
        }
    }

    private func updateInventory() {
        guard let qty = Int(quantity) else {
            updateStatus = "Invalid quantity."
            toastManager.show(message: updateStatus ?? "Invalid quantity.", isSuccess: false)
            return
        }

        let currentUid = Auth.auth().currentUser?.uid ?? "Unknown"

        // Use the reminderDate directly because it has already been initialized
        // as the effective reminder date.
        let newItem = InventoryItem(
            id: "", // Will be set by service.
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

        InventoryService.shared.addInventoryItem(newItem: newItem) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    toastManager.show(message: "Item added successfully!", isSuccess: true)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            onCompletion()
                        }
                    }
                case .failure(let error):
                    updateStatus = "Error updating inventory: \(error.localizedDescription)"
                    toastManager.show(message: updateStatus ?? "Error", isSuccess: false)
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

                        // Set reminderDate using the effective default based on the new category.
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

private let itemDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()
