//
//  HomeView.swift
//  WasteNotMobile
//
//  Created by Ethan Yan on 19/1/25.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        // 1) Use a TabView for the main navigation once user is logged in
        TabView {
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
            
            ScanView()
                .tabItem {
                    Label("Scan", systemImage: "barcode.viewfinder")
                }
            
            FriendsView()
                .tabItem {
                    Label("Friends", systemImage: "person.2")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}
