//
//  LoginView.swift
//  WasteNotMobile
//
//  Created by Ethan Yan on 18/1/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct LoginView: View {
    @ObservedObject var authVM: AuthViewModel
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isSignUp: Bool = false  // Toggle for sign-up vs. login
    @State private var authError: String?
    
    private let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.65, green: 0.85, blue: 1.0),
            Color(red: 0.78, green: 0.92, blue: 1.0)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        ZStack {
            backgroundGradient.ignoresSafeArea()
            
            VStack(spacing: 16) {
                Text(isSignUp ? "Create Account" : "Welcome Back")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.bottom, 8)
                
                VStack(spacing: 20) {
                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    
                    if let error = authError {
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // Display verification message from the view model.
                    if let message = authVM.verificationMessage {
                        Text(message)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    Button(action: {
                        if isSignUp {
                            authVM.signUp(email: email, password: password) { result in
                                switch result {
                                case .success:
                                    authError = nil
                                case .failure(let error):
                                    authError = error.localizedDescription
                                }
                            }
                        } else {
                            authVM.signIn(email: email, password: password) { result in
                                switch result {
                                case .success:
                                    authError = nil
                                case .failure(let error):
                                    authError = error.localizedDescription
                                }
                            }
                        }
                    }) {
                        Text(isSignUp ? "Sign Up" : "Login")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        isSignUp.toggle()
                        authError = nil
                        // Clear any verification message when switching mode.
                        authVM.verificationMessage = nil
                    }) {
                        Text(isSignUp
                             ? "Already have an account? Login"
                             : "Don’t have an account? Sign Up")
                            .foregroundColor(.blue)
                            .underline()
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                .padding(.horizontal, 24)
            }
            .padding()
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
    }
}
