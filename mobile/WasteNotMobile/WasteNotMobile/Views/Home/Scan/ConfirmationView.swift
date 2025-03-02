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
    
    // category and reminder date
    @State private var category: String = "Dairy"
    @State private var categories: [String] = ["Dairy", "Vegetables", "Frozen", "Bakery", "Meat", "Other"]
    @State private var reminderDate: Date = Date()
    @State private var reminderService = ReminderDateService()
    
    // Firestore reference
    private let db = Firestore.firestore()
    
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
                DatePicker("Reminder Date", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])
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
            reminderService.fetchMapping {
                reminderDate = reminderService.defaultReminderDate(for: category)
            }
        }
        .onChange(of: category) { newValue in
            reminderDate = reminderService.defaultReminderDate(for: newValue)
        }
    }
    
    private func updateInventory() {
        guard let qty = Int(quantity) else {
            updateStatus = "Invalid quantity."
            toastManager.show(message: updateStatus ?? "Invalid quantity.", isSuccess: false)
            return
        }
        // Build a new item using the scanned code as barcode.
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
            category: category
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
        // Use the Open Food Facts API v3 endpoint.
        guard let url = URL(string: "https://world.openfoodfacts.org/api/v3/product/\(barcode).json") else {
            print("Invalid URL for Open Food Facts lookup")
            DispatchQueue.main.async {
                self.itemName = "Item: \(barcode)"
            }
            return
        }
        
        print(url)
        
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
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    // Check if the "product" field exists.
                    if let product = jsonResponse["product"] as? [String: Any] {
                        let name = product["product_name"] as? String ?? ""
                        let brand = product["brands"] as? String ?? ""
                        // Combine brand and name as before.
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
                            // Nutrition facts are not directly provided; leave as empty or parse further if needed.
                            self.nutritionFacts = ""
                            self.productImageURL = imageUrl
                            self.category = newCategory
                            self.reminderDate = self.reminderService.defaultReminderDate(for: newCategory)
                        }
                    } else {
                        // Fallback if "product" field isn't found.
                        DispatchQueue.main.async {
                            self.itemName = "Item: \(barcode)"
                        }
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
    
    private func defaultReminderDate(for category: String) -> Date {
        let now = Date()
        var daysToAdd = 7
        switch category {
        case "Dairy":
            daysToAdd = 7
        case "Vegetables":
            daysToAdd = 5
        case "Frozen":
            daysToAdd = 30
        case "Bakery":
            daysToAdd = 3
        case "Meat":
            daysToAdd = 4
        default:
            daysToAdd = 7
        }
        return Calendar.current.date(byAdding: .day, value: daysToAdd, to: now) ?? now
    }
}
