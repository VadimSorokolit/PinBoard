//
//  Authenticator.swift
//  SafeLock
//
//  Created by Divyesh Vekariya on 24/04/24.
//

import Foundation
import LocalAuthentication

enum BiometricType: String {
    case none
    case touchID
    case faceID
    case opticID
}

protocol AuthenticatorProtocol: AnyObject {
    var isAuthenticated: Bool { get set }
    var isPassCodeSet: Bool { get }
    var isBiometricLocked: Bool { get }
    var biometryType: BiometricType { get }
    
    func setPasscodeWith(_ code: String)
    func unlockWithFaceId()
    func verifyPin(pin: String) -> Bool
    func logOut()
}

@Observable
class Authenticator: AuthenticatorProtocol {
    
    // MARK: - Properties. Public
    
    var isAuthenticated: Bool = false
    var isPassCodeSet: Bool = false
    var isBiometricLocked: Bool = false
    var biometryType: BiometricType {
        switch context.biometryType {
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
    
    // MARK: - Properties. Private
    
    
    // MARK: - Properties. Private
    
    private let context = LAContext()
    private let userDefaultSecretKey: String = "secret_key"
    private let maxFailedAttemptAllowed: Int = 3
    private var failedAttempt: Int = 0
    private let userDefault: UserDefaults = .standard
    
    // MARK: - Initializer
    
    init() {
        context.touchIDAuthenticationAllowableReuseDuration = 10
        context.localizedFallbackTitle = ""
        
        isPassCodeSet = !context.isCredentialSet(.applicationPassword)
    }
    
    // MARK: - Methods. Public
    
    func logOut() {
        isAuthenticated = false
        resetFailCount()
    }
    
    func setPasscodeWith(_ code: String) {
        guard isBiometricAvailable() else {
            return
        }
        let key = UUID().uuidString
        let encryptedPasscode = AESEncryptionManager.encrypt(plainText: code, key: key)
        
        userDefault.setValue(encryptedPasscode, forKey: GlobalConstants.userDefaultPasscodeKey)
        userDefault.setValue(key, forKey: userDefaultSecretKey)
        
        isAuthenticated = true
    }
    
    func unlockWithFaceId() {
        authenticate()
    }
    
    func verifyPin(pin: String) -> Bool {
        guard let storedPasscode = decryptUserPasscode() else {
            isAuthenticated = false
            
            return false
        }
        let success = (storedPasscode == pin)
        isAuthenticated = success
        resetFailCount()
        
        return success
    }
    
    func onResetPin() {
        userDefault.removeObject(forKey: GlobalConstants.userDefaultPasscodeKey)
        userDefault.removeObject(forKey: userDefaultSecretKey)
        
        resetFailCount()
    }
    
    // MARK: - Methods. Private
    
    private func authenticate() {
        guard isBiometricAvailable(), !isBiometricLocked else {
            return
        }
        var error: NSError?
        // check whether biometric authentication is possible
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // it's possible, so go ahead and use it
            let reason = "We need to unlock your data."
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self]
                success, authenticationError in
                guard let self else { return }
                // authentication has now completed
                if success {
                    let passcode = decryptUserPasscode()
                    isAuthenticated = passcode != nil
                    // authenticated successfully
                } else {
                    failedAttempt += 1
                    isBiometricLocked = failedAttempt >= maxFailedAttemptAllowed
                }
            }
        } else {
            if let error = error {
                handleLaError(error: error)
            } else {
                
            }
        }
    }
    
    private func decryptUserPasscode() -> String? {
        guard let encryptedPasscode = userDefault.value(forKey: GlobalConstants.userDefaultPasscodeKey) as? String else {
            return nil
        }
        var passcode: String?
        
        if let key = userDefault.value(forKey: userDefaultSecretKey) as? String {
            passcode = AESEncryptionManager.decrypt(encryptedText: encryptedPasscode, key: key)
        }
        
        return passcode
    }
    
    private func resetFailCount() {
        failedAttempt = 0
        isBiometricLocked = false
    }
    
    private func isBiometricAvailable() -> Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
    }
    
    private func handleLaError(error: NSError) {
        if let error = (error as? LAError) {
            var errorMessage: String {
                switch error.code {
                    case .biometryNotAvailable:
                        return "Your device does not supported biometric"
                    case .biometryNotEnrolled:
                        return "Biometric lock is not set please set it first."
                    case .biometryLockout:
                        return "Biometric is locked try entering passcode manually."
                    default:
                        return "Unidentified error"
                }
            }
            print("\(errorMessage)")
        }
    }
    
}


