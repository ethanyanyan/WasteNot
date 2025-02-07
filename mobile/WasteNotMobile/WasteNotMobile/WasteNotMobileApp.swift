//
//  WasteNotMobileApp.swift
//  WasteNotMobile
//
//  Created by Ethan Yan on 7/2/25.
//

import SwiftUI

@main
struct WasteNotMobileApp: App {
    // Keep track of whether the user is logged in
    @State private var isAuthenticated = false

    var body: some Scene {
        WindowGroup {
            if isAuthenticated {
                // Show the main view after login
                HomeTabView()
            } else {
                // Show the login page by default
                LoginView(isAuthenticated: $isAuthenticated)
            }
        }
    }
}
