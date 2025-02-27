//
//  WasteNotApp.swift
//  WasteNot
//
//  Created by Ethan Yan on 18/1/25.
//

import SwiftUI
import FirebaseCore
import UserNotifications
import FirebaseMessaging

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    
    // Set UNUserNotificationCenter delegate and register for remote notifications.
    let center = UNUserNotificationCenter.current()
    center.delegate = self
    application.registerForRemoteNotifications()
    
    return true
  }
  
  // Called when APNs has assigned a device token.
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    // Pass the APNs token to Firebase Messaging.
    Messaging.messaging().apnsToken = deviceToken
    print("APNs device token set: \(deviceToken.map { String(format: "%02.2hhx", $0) }.joined())")
  }
  
  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("Failed to register for remote notifications: \(error.localizedDescription)")
  }
  
  // Optional: Implement UNUserNotificationCenterDelegate methods if needed.
}

@main
struct WasteNotApp: App {
  // Register AppDelegate for Firebase and notifications.
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

  init() {
      // Request notification permissions at app launch.
      NotificationsService.shared.requestNotificationPermissions()
  }
  
  var body: some Scene {
    WindowGroup {
      AppView()
    }
  }
}
