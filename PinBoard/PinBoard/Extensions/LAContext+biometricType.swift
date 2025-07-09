//
//  LAContext+biometricType.swift
//  PinBoard
//
//  Created by Vadim Sorokolit on 07.07.2025.
//
    
import LocalAuthentication

extension LAContext {
    
    var biometricType: BiometricType {
        var error: NSError?
        
        guard self.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        if #available(iOS 11.0, *) {
            switch self.biometryType {
                case .none:
                    return .none
                case .touchID:
                    return .touchID
                case .faceID:
                    return .faceID
                default:
                    if #available(iOS 17.0, *) {
                        if self.biometryType == .opticID {
                            return .opticID
                        } else {
                            return .none
                        }
                    }
            }
        }
        return  self.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) ? .touchID : .none
    }
    
}
