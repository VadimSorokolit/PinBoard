//
//  PinBoardViewModel.swift
//  PinBoard
//
//  Created by Vadim Sorokolit on 08.07.2025.
//

import Foundation

@Observable
class PinBoardViewModel {

    // MARK: - Properties. Public
    
    var passcode = ""
    var isAuthenticated: Bool {
      get { authenticator.isAuthenticated }
      set { authenticator.isAuthenticated = newValue }
    }
    var isBiometricLocked: Bool {
        get { authenticator.isBiometricLocked }
    }
    var biometryType: BiometricType? {
        get { authenticator.biometryType }
    }
    var hideNumberPad: Bool = true
    
    private let authenticator: AuthenticatorProtocol
    
    // MARK: - Inititializer

    init(authenticator: AuthenticatorProtocol) {
        self.authenticator = authenticator
    }
    
    // MARK: - Methods. Public
    
    func registerPasscode() {
        guard self.passcode.count == GlobalConstants.passcodeLength else { return }
        
        self.authenticator.setPasscodeWith(self.passcode)
    }

    func verifyPasscode() -> Bool {
        guard self.passcode.count == GlobalConstants.passcodeLength else {
            return false
        }
        
        let success = self.authenticator.verifyPin(pin: self.passcode)
        
        return success
    }
    
    func onAddValue(_ value: Int) {
        if self.passcode.count < GlobalConstants.passcodeLength {
            self.passcode += "\(value)"
        }
    }
    
    func onRemoveValue() {
        if !self.passcode.isEmpty{
            self.passcode.removeLast()
        }
    }
    
    func onDissmis() {
        self.hideNumberPad = true
    }
    
    func showNumPad() {
        self.hideNumberPad = false
    }
    
    func unlockWithFaceId() {
        self.authenticator.unlockWithFaceId()
    }
    
    func resetAuthenticationState() {
        self.passcode = ""
        self.hideNumberPad = true
        self.authenticator.isAuthenticated = false
    }
    
}
