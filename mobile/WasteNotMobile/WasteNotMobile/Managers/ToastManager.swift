//
//  App/Managers/ToastManager.swift
//  WasteNotMobile
//
//  Created by Ethan Yan on 27/2/25.
//


import SwiftUI

class ToastManager: ObservableObject {
    @Published var message: String = ""
    @Published var isSuccess: Bool = true
    @Published var showToast: Bool = false
    
    func show(message: String, isSuccess: Bool, duration: Double = 2.0) {
        self.message = message
        self.isSuccess = isSuccess
        print("showing toast")
        withAnimation {
            self.showToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            withAnimation {
                self.showToast = false
            }
        }
    }
}
