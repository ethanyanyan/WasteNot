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
  
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken
    print("APNs device token set: \(deviceToken.map { String(format: "%02.2hhx", $0) }.joined())")
  }
  
  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("Failed to register for remote notifications: \(error.localizedDescription)")
  }
}

@main
struct WasteNotApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

  init() {
      NotificationsService.shared.requestNotificationPermissions()
  }
  
  var body: some Scene {
    WindowGroup {
      AppView()
         .environmentObject(ToastManager())
    }
  }
}
