//
//  SensorView.swift
//  WasteNotMobile
//
//  Created by Ethan Yan on 12/2/25.
//

import SwiftUI

struct SensorView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Approach B: IoT Sensor Monitoring")
                .font(.title)
                .padding(.top)
            Text("Simulated sensor output monitoring your fridge activity.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Simulate Sensor Update") {
                // Simulate sensor update action
            }
            .padding()
            List {
                Text("Milk: No movement for 6 days")
                Text("Cheese: No movement for 3 days")
                Text("Lettuce: No movement for 5 days")
            }
            Spacer()
        }
        .navigationTitle("Sensor")
        .padding()
    }
}

struct SensorView_Previews: PreviewProvider {
    static var previews: some View {
        SensorView()
    }
}
