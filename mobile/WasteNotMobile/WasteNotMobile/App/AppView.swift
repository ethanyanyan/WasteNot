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
    @EnvironmentObject var toastManager: ToastManager

    var body: some View {
        ZStack {
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
            // Global toast overlay: it appears on top of everything because of high zIndex.
            if toastManager.showToast {
                ToastView(message: toastManager.message, isSuccess: toastManager.isSuccess)
                    .zIndex(1)
                    .transition(.opacity)
            }
        }
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
            .environmentObject(ToastManager())
    }
}
