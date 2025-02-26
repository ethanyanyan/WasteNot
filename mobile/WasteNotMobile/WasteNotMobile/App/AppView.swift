//
//  AppView.swift
//  WasteNot
//
//  Created by Ethan Yan on 19/1/25.
//

import SwiftUI
import FirebaseAuth

struct AppView: View {
    @StateObject var authVM = AuthViewModel()
    
    var body: some View {
        NavigationView {
            Group {
                if let user = authVM.currentUser, user.isEmailVerified {
                    HomeView()
                } else {
                    // Pass the authVM so that LoginView can display the verification message.
                    LoginView(authVM: authVM)
                }
            }
        }
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
