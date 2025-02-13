//
//  HomeTabView.swift
//  WasteNotMobile
//
//  Created by Ethan Yan on 12/2/25.
//

import SwiftUI

struct HomeTabView: View {
    @State private var selectedTab: Int = 0
    @EnvironmentObject var prototypeSettings: PrototypeSettings

    var body: some View {
        TabView(selection: $selectedTab) {
            // Inventory Tab (common to all approaches)
            NavigationView {
                InventoryView()
            }
            .tabItem {
                Image(systemName: "list.bullet.rectangle")
                Text("Inventory")
            }
            .tag(0)

            // Approach A: Show Scan and Recipes tabs
            if prototypeSettings.currentApproach == .approachA {
                NavigationView {
                    ScanView()
                }
                .tabItem {
                    Image(systemName: "camera.viewfinder")
                    Text("Scan")
                }
                .tag(1)
                
                NavigationView {
                    RecipesView()
                }
                .tabItem {
                    Image(systemName: "book")
                    Text("Recipes")
                }
                .tag(2)
                
                NavigationView {
                    ProfileView()
                }
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Profile")
                }
                .tag(3)
            }
            // Approach B: Show Sensor and Recipes tabs
            else if prototypeSettings.currentApproach == .approachB {
                NavigationView {
                    SensorView()
                }
                .tabItem {
                    Image(systemName: "wifi")
                    Text("Sensor")
                }
                .tag(1)
                
                NavigationView {
                    RecipesView()
                }
                .tabItem {
                    Image(systemName: "book")
                    Text("Recipes")
                }
                .tag(2)
                
                NavigationView {
                    ProfileView()
                }
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Profile")
                }
                .tag(3)
            }
            // Approach C: Show Swap tab (no recipes)
            else if prototypeSettings.currentApproach == .approachC {
                NavigationView {
                    CommunitySwapView()
                }
                .tabItem {
                    Image(systemName: "person.3")
                    Text("Swap")
                }
                .tag(1)
                
                NavigationView {
                    ProfileView()
                }
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Profile")
                }
                .tag(2)
            }
        }
    }
}

struct HomeTabView_Previews: PreviewProvider {
    static var previews: some View {
        HomeTabView()
            .environmentObject(PrototypeSettings())
    }
}
