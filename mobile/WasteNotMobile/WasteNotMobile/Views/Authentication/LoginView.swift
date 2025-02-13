//
//  LoginView.swift
//  WasteNotMobile
//
//  Created by Ethan Yan on 7/2/25.
//


import SwiftUI

struct LoginView: View {
    // Binding so can update login state
    @Binding var isAuthenticated: Bool

    @State private var username = ""
    @State private var password = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("WasteNot Login")
                .font(.largeTitle)
                .padding(.top, 40)

            // Username Field
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 40)

            // Password Field
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 40)

            // Login Button
            Button("Login") {
                // Temp
                isAuthenticated = true
            }
            .padding(.top, 20)

            Spacer()
        }
        .padding()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        // For preview, pass a constant binding
        LoginView(isAuthenticated: .constant(false))
    }
}
