//
//  Managers/UserSettingsManager.swift
//  WasteNotMobile
//
//  Created by Ethan Yan on 12/4/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class UserSettingsManager: ObservableObject {
    static let shared = UserSettingsManager()
    
    @Published var defaultNotificationLeadTime: Double = 24.0  // in hours
    
    private let db = Firestore.firestore()
    
    private init() {
        loadSettings()
    }
    
    func loadSettings() {
        guard let user = Auth.auth().currentUser else { return }
        db.collection("users").document(user.uid).getDocument { snapshot, error in
            if let data = snapshot?.data(), let leadTime = data["notificationLeadTime"] as? Double {
                DispatchQueue.main.async {
                    self.defaultNotificationLeadTime = leadTime
                }
            }
        }
    }
}
