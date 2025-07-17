//
//  Color+hexInt.swift
//  PinBoard
//
//  Created by Vadim Sorokolit on 10.07.2025.
//

import SwiftUI
    
extension Color {

    init(hex: Int, opacity: Double = 1.0) {
        self.init(
            red: Double((hex >> 16) & 0xff) / 255.0,
            green: Double((hex >> 08) & 0xff) / 255.0,
            blue: Double((hex >> 00) & 0xff) / 255.0,
            opacity: opacity
        )
    }

}
