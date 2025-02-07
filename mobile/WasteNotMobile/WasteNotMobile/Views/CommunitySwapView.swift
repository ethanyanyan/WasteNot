//
//  CommunitySwapView.swift
//  WasteNotMobile
//
//  Created by Ethan Yan on 7/2/25.
//


import SwiftUI

struct CommunitySwapView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Community Swap")
                .font(.title)
                .padding()

            Text("Placeholder for listing or finding surplus items...")
                .padding()

            Spacer()
        }
        .navigationTitle("Community Swap")
    }
}

struct CommunitySwapView_Previews: PreviewProvider {
    static var previews: some View {
        CommunitySwapView()
    }
}
