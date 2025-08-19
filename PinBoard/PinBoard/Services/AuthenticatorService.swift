//
//  AuthenticatorService.swift
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
    func unlockBiometry()
    func verifyPin(pin: String) -> Bool
    func logOut()
}

protocol AuthenticatorDelegate {
    func authenticator(_ authenticator: AuthenticatorProtocol, didFailWith message: String)
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
    var delegate: AuthenticatorDelegate?
    
    // MARK: - Properties. Private
    
    private var context = LAContext()
    private let userDefaultSecretKey: String = "secret key"
    private let maxFailedAttemptAllowed: Int = 3
    private var failedAttempt: Int = .zero
    
    // MARK: - Initializer
    
    init() {
        self.context.touchIDAuthenticationAllowableReuseDuration = 10.0
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
        let encryptedPasscode = AESEncryptionService.encrypt(plainText: code, key: key)
        
        UserDefaults.standard.setValue(encryptedPasscode, forKey: GlobalConstants.userDefaultPasscodeKey)
        UserDefaults.standard.setValue(key, forKey: self.userDefaultSecretKey)
        
        self.isAuthenticated = true
    }
    
    func unlockBiometry() {
        self.authenticate()
    }
    
    func verifyPin(pin: String) -> Bool {
        guard let storedPasscode = self.decryptUserPasscode() else {
            self.isAuthenticated = false
            
            return false
        }
        let success = (storedPasscode == pin)
        self.isAuthenticated = success
        self.resetFailCount()
        
        return success
    }
    
    func onResetPin() {
        UserDefaults.standard.removeObject(forKey: GlobalConstants.userDefaultPasscodeKey)
        UserDefaults.standard.removeObject(forKey: self.userDefaultSecretKey)
        
        self.resetFailCount()
    }
    
    // MARK: - Methods. Private
    
    private func authenticate() {
        guard self.isBiometricAvailable() else {
            return
        }
        var error: NSError?
        // check whether biometric authentication is possible
        if self.context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            // it's possible, so go ahead and use it
            let reason = "We need to unlock your data."
            self.context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { [weak self]
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
    
    private func resetFailCount() {
        self.failedAttempt = .zero
        self.isBiometricLocked = false
        self.context.invalidate()
        self.context = LAContext()
    }
    
    private func decryptUserPasscode() -> String? {
        guard let encryptedPasscode = UserDefaults.standard.value(forKey: GlobalConstants.userDefaultPasscodeKey) as? String else {
            return nil
        }
        var passcode: String?
        
        if let key = UserDefaults.standard.value(forKey: self.userDefaultSecretKey) as? String {
            passcode = AESEncryptionService.decrypt(encryptedText: encryptedPasscode, key: key)
        }
        
        return passcode
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
            self.delegate?.authenticator(self, didFailWith: errorMessage)
        }
    }
    
}
