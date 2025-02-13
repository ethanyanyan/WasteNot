//
//  DebugApproachSelector.swift
//  WasteNotMobile
//
//  Created by Ethan Yan on 12/2/25.
//

import SwiftUI

struct DebugApproachSelector: View {
    @EnvironmentObject var prototypeSettings: PrototypeSettings

    var body: some View {
        Picker("Select Prototype Approach", selection: $prototypeSettings.currentApproach) {
            ForEach(PrototypeApproach.allCases) { approach in
                Text(approach.rawValue).tag(approach)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
    }
}

struct DebugApproachSelector_Previews: PreviewProvider {
    static var previews: some View {
        DebugApproachSelector()
            .environmentObject(PrototypeSettings())
    }
}
