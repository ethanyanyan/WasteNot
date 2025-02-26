//
//  WasteNotApp.swift
//  WasteNot
//
//  Created by Ethan Yan on 18/1/25.
//

import SwiftUI
import FirebaseCore
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct WasteNotApp: App {
  // Register app delegate for Firebase setup.
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
