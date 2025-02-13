//
//  PrototypeApproach.swift
//  WasteNotMobile
//
//  Created by Ethan Yan on 12/2/25.
//

import SwiftUI

enum PrototypeApproach: String, CaseIterable, Identifiable {
    case approachA = "Barcode/Receipt Scanning"
    case approachB = "Smart Fridge Sensor"
    case approachC = "Community Swap/Donation"
    
    var id: String { self.rawValue }
}

final class PrototypeSettings: ObservableObject {
    @Published var currentApproach: PrototypeApproach = .approachA
}
