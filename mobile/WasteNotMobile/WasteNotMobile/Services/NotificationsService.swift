//
//  NotificationsService.swift
//  WasteNotMobile
//
//  Created by Ethan Yan on 26/2/25.
//

import Foundation
import UserNotifications
import FirebaseFirestore
import FirebaseAuth

class NotificationsService {
    static let shared = NotificationsService()
    
    private lazy var db: Firestore = {
        return Firestore.firestore()
    }()
    
    private init() {}
    
    // MARK: - Local Notification Methods
    
    func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            } else {
                print("Notification permission granted: \(granted)")
            }
        }
    }
    
    func scheduleReminder(for item: InventoryItem) {
        guard let reminderDate = item.reminderDate else {
            print("No reminder date provided for item: \(item.itemName)")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Reminder: \(item.itemName)"
        content.body = "It's time to use your \(item.itemName)!"
        content.sound = .default
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: item.id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling reminder: \(error.localizedDescription)")
            } else {
                print("Scheduled reminder for \(item.itemName) at \(reminderDate)")
            }
        }
    }
    
    func cancelReminder(for item: InventoryItem) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [item.id])
    }
    
    // MARK: - Inventory Invitations Methods
    
    func createInventoryInvitation(from fromUID: String, to toUID: String, inventoryId: String, inventoryName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let invitationData: [String: Any] = [
            "fromUser": fromUID,
            "toUser": toUID,
            "inventoryId": inventoryId,
            "inventoryName": inventoryName,  // Store the inventory name.
            "status": "pending",
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        db.collection("invitations").addDocument(data: invitationData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func fetchPendingInvitations(completion: @escaping (Result<[InventoryInvitation], Error>) -> Void) {
        guard let currentUID = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "NotificationsService", code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "User not logged in."])))
            return
        }
        
        db.collection("invitations")
            .whereField("toUser", isEqualTo: currentUID)
            .whereField("status", isEqualTo: "pending")
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else if let snapshot = snapshot {
                    let invitations = snapshot.documents.compactMap { doc -> InventoryInvitation? in
                        let data = doc.data()
                        guard let fromUser = data["fromUser"] as? String,
                              let toUser = data["toUser"] as? String,
                              let inventoryId = data["inventoryId"] as? String,
                              let inventoryName = data["inventoryName"] as? String,
                              let status = data["status"] as? String,
                              let ts = data["createdAt"] as? Timestamp
                        else { return nil }
                        return InventoryInvitation(id: doc.documentID, fromUser: fromUser, toUser: toUser, inventoryId: inventoryId, inventoryName: inventoryName, status: status, createdAt: ts.dateValue())
                    }
                    completion(.success(invitations))
                }
            }
    }
    
    func updateInvitationStatus(invitationId: String, newStatus: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("invitations").document(invitationId).updateData(["status": newStatus]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func acceptInventoryInvitation(_ invitation: InventoryInvitation, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUID = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "NotificationsService", code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "User not logged in."])))
            return
        }
        
        updateInvitationStatus(invitationId: invitation.id, newStatus: "accepted") { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success:
                let updateData: [String: Any] = [
                    "members.\(currentUID)": "member",
                    "membersArray": FieldValue.arrayUnion([currentUID])
                ]
                self.db.collection("inventories").document(invitation.inventoryId).updateData(updateData) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            }
        }
    }
    
    func declineInventoryInvitation(_ invitation: InventoryInvitation, completion: @escaping (Result<Void, Error>) -> Void) {
        updateInvitationStatus(invitationId: invitation.id, newStatus: "declined", completion: completion)
    }
    
    func checkExistingInvitation(to invitedUID: String, forInventory inventoryId: String, from currentUID: String, completion: @escaping (Bool) -> Void) {
        db.collection("invitations")
          .whereField("toUser", isEqualTo: invitedUID)
          .whereField("inventoryId", isEqualTo: inventoryId)
          .whereField("fromUser", isEqualTo: currentUID)
          .whereField("status", isEqualTo: "pending")
          .getDocuments { snapshot, error in
              if let error = error {
                  print("Error checking invitation: \(error.localizedDescription)")
                  completion(false)
              } else if let snapshot = snapshot {
                  print("Found \(snapshot.documents.count) matching invitation(s)")
                  for doc in snapshot.documents {
                      print("Existing invitation document: \(doc.documentID), data: \(doc.data())")
                  }
                  completion(!snapshot.documents.isEmpty)
              } else {
                  print("No snapshot returned")
                  completion(false)
              }
          }
    }
}
