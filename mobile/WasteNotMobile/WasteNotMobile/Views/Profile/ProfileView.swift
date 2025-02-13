//
//  ProfileView.swift
//  WasteNotMobile
//
//  Created by Ethan Yan on 7/2/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var prototypeSettings: PrototypeSettings

    var body: some View {
        VStack(spacing: 20) {
            // Debug toggle appears only on the Profile page.
            DebugApproachSelector()
            
            Text("Your Profile")
                .font(.largeTitle)
                .padding(.top, 40)
            
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.gray)
            
            Text("Username: JohnDoe123")
            Text("Email: john.doe@example.com")
            Text("Member Since: 2025")
            
            Spacer()
        }
        .navigationTitle("Profile")
        .padding()
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(PrototypeSettings())
    }
}
