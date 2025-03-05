//
//  Services/ReminderDateService.swift
//  WasteNotMobile
//
//  Created by Ethan Yan on 2/3/25.
//

import Foundation
import FirebaseRemoteConfig

class ReminderDateService {
    
    // Default mapping; this will be updated by Remote Config.
    private(set) var categoryMapping: [String: Int] = [
        "dairy": 7,
        "milk": 7,
        "cheese": 7,
        "vegetable": 5,
        "frozen": 30,
        "bakery": 3,
        "meat": 4
    ]
    
    /// Fetches the latest mapping from Firebase Remote Config.
    /// The Remote Config parameter "categoryReminderMapping" should be a JSON string.
    func fetchMapping(completion: @escaping () -> Void) {
        let remoteConfig = RemoteConfig.remoteConfig()
        // Set local default values if needed.
        let defaults: [String: NSObject] = [
            "categoryReminderMapping": "{\"dairy\":7,\"milk\":7,\"cheese\":7,\"vegetable\":5,\"frozen\":30,\"bakery\":3,\"meat\":4}" as NSObject
        ]
        remoteConfig.setDefaults(defaults)
        
        // Force fetch for testing by setting expiration to 0.
        remoteConfig.fetch(withExpirationDuration: 0) { status, error in
            if let error = error {
                print("Remote Config fetch error: \(error.localizedDescription)")
                completion()
                return
            }
            remoteConfig.activate { (changed, error) in
                if let error = error {
                    print("Remote Config activation error: \(error.localizedDescription)")
                }
                let mappingString = remoteConfig["categoryReminderMapping"].stringValue
                print("Remote Config mappingString: \(mappingString)")
                if let data = mappingString.data(using: .utf8) {
                    do {
                        let mapping = try JSONDecoder().decode([String: Int].self, from: data)
                        self.categoryMapping = mapping
                    } catch {
                        print("Error decoding Remote Config mapping: \(error.localizedDescription)")
                    }
                }
                completion()
            }
        }
    }
    
    /// Returns a reminder date based on fuzzy (substring) matching of the provided category string.
    func defaultReminderDate(for category: String, from referenceDate: Date = Date()) -> Date {
        let lowerCategory = category.lowercased()
        var bestMatchDays = 7  // Default interval
        var highestMatchScore = 0

        // Compare against lowercased keyword
        for (keyword, days) in categoryMapping {
            let lowerKeyword = keyword.lowercased()
            if lowerCategory.contains(lowerKeyword) {
                let score = lowerKeyword.count
                if score > highestMatchScore {
                    highestMatchScore = score
                    bestMatchDays = days
                }
            }
        }
        return Calendar.current.date(byAdding: .day, value: bestMatchDays, to: referenceDate) ?? referenceDate
    }

}
