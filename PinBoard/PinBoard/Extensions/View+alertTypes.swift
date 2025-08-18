//
//  View+alertTypes.swift
//  PinBoard
//
//  Created by Vadim Sorokolit on 18.08.2025.
//
 
import Foundation
import SwiftUI

extension View {
    
    func localAlert(_ alert: Binding<AppAlertType?>) -> some View {
        modifier(Alert.AlertOverlayModifier(type: alert))
    }
    
    func environmentAlert(_ alert: Binding<AppAlertType?>) -> some View {
        self.environment(\.appAlert, alert)
            .modifier(Alert.AlertOverlayModifier(type: alert))
    }
    
}
