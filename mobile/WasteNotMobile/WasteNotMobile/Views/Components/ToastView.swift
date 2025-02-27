//
//  Views/Components/ToastView.swift
//  WasteNotMobile
//
//  Created by Ethan Yan on 27/2/25.
//


import SwiftUI

struct ToastView: View {
    let message: String
    let isSuccess: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Image(systemName: isSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isSuccess ? .green : .red)
                .font(.title2)
            Text(message)
                .foregroundColor(.white)
                .font(.body)
                .multilineTextAlignment(.leading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.black.opacity(0.8))
        .cornerRadius(8)
        .shadow(radius: 10)
    }
}

struct ToastView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            ToastView(message: "Operation succeeded!", isSuccess: true)
            ToastView(message: "Operation failed.", isSuccess: false)
        }
        .padding()
        .background(Color.gray)
    }
}
