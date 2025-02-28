//
//  HomeView.swift
//  WasteNotMobile
//
//  Created by Ethan Yan on 19/1/25.
//

import SwiftUI

enum Tab {
    case inventory, scan, friends, profile
}

struct HomeView: View {
    @State private var selectedTab: Tab = .inventory
    @StateObject var toastManager = ToastManager()
    
    var body: some View {
        // 1) Use a TabView for the main navigation once user is logged in
        TabView(selection: $selectedTab) {
//            FeedView()
//                .tabItem {
//                    Label("Feed", systemImage: "house")
//                }

//            PostView()
//                .tabItem {
//                    Label("Post", systemImage: "plus.circle")
//                }
            
            InventoryView()
                .tabItem {
                    Label("Inventory", systemImage: "tray.full")
                }
                .tag(Tab.inventory)
            
            ScanView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Scan", systemImage: "barcode.viewfinder")
                }
                .tag(Tab.scan)
            
            FriendsView()
                .tabItem {
                    Label("Friends", systemImage: "person.2")
                }
                .tag(Tab.friends)

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(Tab.profile)
        }
        .environmentObject(toastManager)
    }
}
