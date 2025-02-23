//
//  AuthViewModel.swift
//  WasteNotMobile
//
//  Created by Ethan Yan on 23/2/25.
//

import Foundation
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var currentUser: User? = Auth.auth().currentUser
    @Published var verificationMessage: String? = nil
    
    init() {
        // Listen for auth state changes
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            if let user = user {
                // Reload the user to get the latest email verification status.
                user.reload { error in
                    DispatchQueue.main.async {
                        if let error = error {
                            print("Reload error: \(error.localizedDescription)")
                        } else if user.isEmailVerified {
                            self.currentUser = user
                            self.verificationMessage = nil
                        } else {
                            // If not verified, sign out and set verification message.
                            do {
                                try Auth.auth().signOut()
                            } catch {
                                print("Error signing out: \(error.localizedDescription)")
                            }
                            self.currentUser = nil
                            self.verificationMessage = "Please verify your email before logging in. Check your inbox for a verification email."
                        }
                    }
                }
            } else {
                self.currentUser = nil
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else if let user = Auth.auth().currentUser {
                    user.reload { error in
                        DispatchQueue.main.async {
                            if let error = error {
                                completion(.failure(error))
                            } else if !user.isEmailVerified {
                                do {
                                    try Auth.auth().signOut()
                                } catch {
                                    print("Error signing out: \(error.localizedDescription)")
                                }
                                self?.verificationMessage = "Please verify your email before logging in. Check your inbox for a verification email."
                                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Email not verified."])))
                            } else {
                                self?.currentUser = user
                                self?.verificationMessage = nil
                                completion(.success(()))
                            }
                        }
                    }
                }
            }
        }
    }
    
    func signUp(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else if let user = authResult?.user {
                    user.sendEmailVerification { emailError in
                        DispatchQueue.main.async {
                            if let emailError = emailError {
                                completion(.failure(emailError))
                            } else {
                                do {
                                    try Auth.auth().signOut()
                                } catch {
                                    print("Error signing out: \(error.localizedDescription)")
                                }
                                self?.verificationMessage = "Sign up successful. A verification email has been sent. Please verify your email before logging in."
                                completion(.success(()))
                            }
                        }
                    }
                }
            }
        }
    }
}
