//
//  LAContext+biometricType.swift
//  PinBoard
//
//  Created by Vadim Sorokolit on 07.07.2025.
//

import Foundation
import LocalAuthentication

extension LAContext {
    
    var biometricType: BiometricType {
        _ = canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
        
        switch biometryType {
            case .touchID:
                return .touchID
            case .faceID:
                return .faceID
            case .opticID:
                return .opticID
            default:
                return .none
        }
    }
    
}
