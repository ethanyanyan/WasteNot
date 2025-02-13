//
//  WasteNotMobileApp.swift
//  WasteNotMobile
//
//  Created by Ethan Yan on 7/2/25.
//

import SwiftUI

@main
struct WasteNotMobileApp: App {
    @State private var isAuthenticated = false
    @StateObject var prototypeSettings = PrototypeSettings()  // shared settings

    var body: some Scene {
        WindowGroup {
            if isAuthenticated {
                HomeTabView()
                    .environmentObject(prototypeSettings)
            } else {
                LoginView(isAuthenticated: $isAuthenticated)
                    .environmentObject(prototypeSettings)
            }
        }
    }
}
