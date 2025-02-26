//
//  Services/NotificationsService.swift
//  WasteNotMobile
//
//  Created by Ethan Yan on 26/2/25.
//

import Foundation
import UserNotifications

class NotificationsService {
    static let shared = NotificationsService()
    
    private init() {}
    
    /// Call this early in your app's lifecycle to request notification permissions.
    func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            } else {
                print("Notification permission granted: \(granted)")
            }
        }
    }
    
    /// Schedules a local notification for the given inventory item.
    func scheduleReminder(for item: InventoryItem) {
        guard let reminderDate = item.reminderDate else {
            print("No reminder date provided for item: \(item.itemName)")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Reminder: \(item.itemName)"
        content.body = "It's time to use your \(item.itemName)!"
        content.sound = .default
        
        // Create date components that include the seconds for better precision.
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
}
