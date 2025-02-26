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
    
    // New fields: category and reminder date
    @State private var category: String = "Dairy"
    let categories = ["Dairy", "Vegetables", "Frozen", "Bakery", "Meat", "Other"]
    @State private var reminderDate: Date = Date()
    
    // Firestore reference
    private let db = Firestore.firestore()
    
    // Load BarcodeLookup API key from Secrets.plist
    private var barcodeLookupAPIKey: String {
        guard let filePath = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: filePath),
              let key = plist["BarcodeLookupAPIKey"] as? String else {
            fatalError("Could not load API key from Secrets.plist")
        }
        return key
    }
    
    var body: some View {
        NavigationView {
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
                
                if let status = updateStatus {
                    Section {
                        Text(status)
                            .foregroundColor(.green)
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
                reminderDate = defaultReminderDate(for: category)
            }
            .onChange(of: category, perform: { newValue in
                reminderDate = defaultReminderDate(for: newValue)
            })
        }
    }
    
    private func updateInventory() {
        guard let qty = Int(quantity) else {
            updateStatus = "Invalid quantity."
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
                    updateStatus = "Inventory updated successfully!"
                    onCompletion()
                case .failure(let error):
                    updateStatus = "Error updating inventory: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func lookupProduct(for barcode: String) {
        guard let url = URL(string: "https://api.barcodelookup.com/v3/products?barcode=\(barcode)&key=\(barcodeLookupAPIKey)") else {
            print("Invalid URL for barcode lookup")
            DispatchQueue.main.async {
                self.itemName = "Item: \(barcode)"
            }
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Barcode lookup error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.itemName = "Item: \(barcode)"
                }
                return
            }
            guard let data = data else {
                print("No data received from barcode lookup")
                DispatchQueue.main.async {
                    self.itemName = "Item: \(barcode)"
                }
                return
            }
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("Barcode Lookup JSON Response: \(jsonResponse)")
                    if let products = jsonResponse["products"] as? [[String: Any]],
                       let firstProduct = products.first {
                        let brand = firstProduct["brand"] as? String ?? ""
                        let title = firstProduct["title"] as? String ?? ""
                        let defaultName: String = brand.isEmpty ? title : (title.isEmpty ? brand : "\(brand) \(title)")
                        let description = firstProduct["description"] as? String ?? ""
                        let ingredientsValue = firstProduct["ingredients"] as? String ?? ""
                        let nutrition = firstProduct["nutrition_facts"] as? String ?? ""
                        let images = firstProduct["images"] as? [String] ?? []
                        let imageURL = images.first ?? ""
                        
                        DispatchQueue.main.async {
                            self.itemName = defaultName.isEmpty ? "Item: \(barcode)" : defaultName
                            self.productBrand = brand
                            self.productTitle = title
                            self.productDescription = description
                            self.ingredients = ingredientsValue
                            self.nutritionFacts = nutrition
                            self.productImageURL = imageURL
                        }
                    } else {
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
                print("Error parsing barcode lookup response: \(error.localizedDescription)")
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
