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
        switch self.context.biometryType {
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
    
    private let context = LAContext()
    private let userDefaultSecretKey: String = "secret_key"
    private let maxFailedAttemptAllowed: Int = 3
    private var failedAttempt: Int = 0
    private let userDefault: UserDefaults = .standard
    
    // MARK: - Initializer
    
    init() {
        self.context.touchIDAuthenticationAllowableReuseDuration = 10
        self.context.localizedFallbackTitle = ""
        
        self.isPassCodeSet = !self.context.isCredentialSet(.applicationPassword)
    }
    
    // MARK: - Methods. Public
    
    func logOut() {
        self.isAuthenticated = false
        self.resetFailCount()
    }
    
    func setPasscodeWith(_ code: String) {
        guard self.isBiometricAvailable() else {
            return
        }
        let key = UUID().uuidString
        let encryptedPasscode = AESEncryptionManager.encrypt(plainText: code, key: key)
        
        self.userDefault.setValue(encryptedPasscode, forKey: GlobalConstants.userDefaultPasscodeKey)
        self.userDefault.setValue(key, forKey: self.userDefaultSecretKey)
        
        self.isAuthenticated = true
    }
    
    func unlockWithFaceId() {
        self.authenticate()
    }
    
    func verifyPin(pin: String) -> Bool {
        guard let storedPasscode = decryptUserPasscode() else {
            self.isAuthenticated = false
            
            return false
        }
        let success = (storedPasscode == pin)
        self.isAuthenticated = success
        self.resetFailCount()
        
        return success
    }
    
    func onResetPin() {
        self.userDefault.removeObject(forKey: GlobalConstants.userDefaultPasscodeKey)
        self.userDefault.removeObject(forKey: self.userDefaultSecretKey)
        
        self.resetFailCount()
    }
    
    // MARK: - Methods. Private
    
    private func authenticate() {
        guard self.isBiometricAvailable(), !self.isBiometricLocked else {
            return
        }
        var error: NSError?
        // check whether biometric authentication is possible
        if self.context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // it's possible, so go ahead and use it
            let reason = "We need to unlock your data."
            self.context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self]
                success, authenticationError in
                guard let self else { return }
                // authentication has now completed
                if success {
                    let passcode = self.decryptUserPasscode()
                    self.isAuthenticated = passcode != nil
                    // authenticated successfully
                } else {
                    self.failedAttempt += 1
                    self.isBiometricLocked = self.failedAttempt >= self.maxFailedAttemptAllowed
                }
            }
        } else {
            if let error = error {
                self.handleLaError(error: error)
            } else {
                
            }
        }
    }
    
    private func decryptUserPasscode() -> String? {
        guard let encryptedPasscode = self.userDefault.value(forKey: GlobalConstants.userDefaultPasscodeKey) as? String else {
            return nil
        }
        var passcode: String?
        
        if let key = self.userDefault.value(forKey: self.userDefaultSecretKey) as? String {
            passcode = AESEncryptionManager.decrypt(encryptedText: encryptedPasscode, key: key)
        }
        
        return passcode
    }
    
    private func resetFailCount() {
        self.failedAttempt = 0
        self.isBiometricLocked = false
    }
    
    private func isBiometricAvailable() -> Bool {
        return self.context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
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


