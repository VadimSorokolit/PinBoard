//
//  EnvironmentValues+appAlert.swift
//  PinBoard
//
//  Created by Vadim Sorokolit on 18.08.2025.
//

import Foundation
import SwiftUI

extension EnvironmentValues {
    
    var appAlert: Binding<Alert.Notice?> {
        get { self[Alert.Key.self] }
        set { self[Alert.Key.self] = newValue }
    }
    
}
