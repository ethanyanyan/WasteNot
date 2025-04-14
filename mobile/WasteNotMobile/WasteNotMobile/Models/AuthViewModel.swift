//
//  AuthViewModel.swift
//  WasteNotMobile
//
//  Created by Ethan Yan on 23/2/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseMessaging

class AuthViewModel: ObservableObject {
    @Published var currentUser: User? = Auth.auth().currentUser
    @Published var verificationMessage: String? = nil
    var isSigningUp: Bool = false  // Flag to bypass verification check during sign-up
    
    init() {
        // Listen for auth state changes.
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            
            // Bypass email verification check if sign up is in progress.
            if self.isSigningUp {
                print("Skipping auth listener check because sign up is in progress.")
                return
            }
            
            if let user = user {
                // Reload user to check email verification status.
                user.reload { error in
                    DispatchQueue.main.async {
                        if let error = error {
                            print("Reload error: \(error.localizedDescription)")
                        } else if user.isEmailVerified {
                            self.currentUser = user
                            self.verificationMessage = nil
                            self.updateFCMToken()
                        } else {
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
    
    // Retrieve the FCM token and store it in Firestore.
    private func updateFCMToken() {
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM token: \(error.localizedDescription)")
                return
            }
            guard let token = token, let user = Auth.auth().currentUser else {
                return
            }
            let db = Firestore.firestore()
            db.collection("users").document(user.uid).updateData(["fcmToken": token]) { error in
                if let error = error {
                    print("Error updating FCM token in Firestore: \(error.localizedDescription)")
                } else {
                    print("Successfully updated FCM token for user: \(user.uid)")
                }
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] _, error in
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
                                self?.updateFCMToken()
                                completion(.success(()))
                            }
                        }
                    }
                }
            }
        }
    }
    
    func signUp(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Set the flag before starting the sign-up process.
        isSigningUp = true
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let error = error {
                    self.isSigningUp = false
                    completion(.failure(error))
                } else if let user = authResult?.user {
                    let db = Firestore.firestore()
                    db.collection("users").document(user.uid).setData([
                        "email": email,
                        "createdAt": FieldValue.serverTimestamp()
                    ]) { error in
                        if let error = error {
                            self.isSigningUp = false
                            completion(.failure(error))
                        } else {
                            user.sendEmailVerification { emailError in
                                DispatchQueue.main.async {
                                    // Reset the flag after the sign-up flow has finished.
                                    self.isSigningUp = false
                                    if let emailError = emailError {
                                        completion(.failure(emailError))
                                    } else {
                                        do {
                                            try Auth.auth().signOut()
                                        } catch {
                                            print("Error signing out: \(error.localizedDescription)")
                                        }
                                        self.verificationMessage = "Sign up successful. A verification email has been sent. Please verify your email before logging in."
                                        completion(.success(()))
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
