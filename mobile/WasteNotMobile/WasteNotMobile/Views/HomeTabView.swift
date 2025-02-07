//
//  HomeTabView.swift
//  WasteNotMobile
//
//  Created by Ethan Yan on 7/2/25.
//


import SwiftUI

struct HomeTabView: View {
    @State private var selectedTab: Int = 0  // Default tab index

    var body: some View {
        TabView(selection: $selectedTab) {
            // Inventory Tab
            NavigationView {
                InventoryView()
            }
            .tabItem {
                Image(systemName: "list.bullet.rectangle")
                Text("Inventory")
            }
            .tag(0)

            // Scan Tab
            NavigationView {
                ScanView()
            }
            .tabItem {
                Image(systemName: "camera.viewfinder")
                Text("Scan")
            }
            .tag(1)

            // Community Swap Tab
            NavigationView {
                CommunitySwapView()
            }
            .tabItem {
                Image(systemName: "person.3")
                Text("Swap")
            }
            .tag(2)

            // Profile Tab
            NavigationView {
                ProfileView()
            }
            .tabItem {
                Image(systemName: "person.crop.circle")
                Text("Profile")
            }
            .tag(3)
        }
    }
}

struct HomeTabView_Previews: PreviewProvider {
    static var previews: some View {
        HomeTabView()
    }
}
