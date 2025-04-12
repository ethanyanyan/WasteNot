//
//  Services/UserService.swift
//  WasteNotMobile
//
//  Created by Ethan Yan on [Date].
//

import FirebaseFirestore
import FirebaseAuth

class UserService {
    private let db = Firestore.firestore()

    func fetchUserProfile(uid: String, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else if let snapshot = snapshot, snapshot.exists, let data = snapshot.data() {
                let username = data["username"] as? String ?? "Unknown"
                let email = data["email"] as? String ?? ""
                let profile = UserProfile(id: uid, username: username, email: email)
                completion(.success(profile))
            } else {
                completion(.failure(NSError(domain: "UserService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found."])))
            }
        }
    }
    
    func fetchUserProfileByEmail(email: String, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else if let snapshot = snapshot, let doc = snapshot.documents.first, doc.exists {
                let uid = doc.documentID
                let data = doc.data()
                let username = data["username"] as? String ?? "Unknown"
                let email = data["email"] as? String ?? ""
                completion(.success(UserProfile(id: uid, username: username, email: email)))
            } else {
                completion(.failure(NSError(domain: "UserService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found."])))
            }
        }
    }
}
