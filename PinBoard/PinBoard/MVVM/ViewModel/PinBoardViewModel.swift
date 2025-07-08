//
//  PinBoardViewModel.swift
//  PinBoard
//
//  Created by Vadim Sorokolit on 08.07.2025.
//

import SwiftUI

@Observable
class PinBoardViewModel {
    
    // Objects
    
    struct Constants {
        static let passcodeLength: Int = 4
    }
    
    // MARK: - Properties. Public
    
    @ObservationIgnored let passcodeLength: Int = Constants.passcodeLength
    var passcode = ""
    var isUnlocked: Bool {
      get { authenticator.isAuthenticated }
      set { authenticator.isAuthenticated = newValue }
    }
    var authenticator: Authenticator
    var hideNumberPad: Bool = true
    
    // MARK: - Inititializer

    init(authenticator: Authenticator) {
        self.authenticator = authenticator
    }
    
    // MARK: - Methods. Public
    
    func registerPasscode() {
        guard self.passcode.count == self.passcodeLength else { return }
        
        authenticator.setPasscodeWith(self.passcode)
    }

    func verifyPasscode() -> Bool {
        guard passcode.count == passcodeLength else {
            return false
        }
        
        let success = self.authenticator.verifyPin(pin: passcode)
        
        return success
    }
    
    func onAddValue(_ value: Int) {
        if passcode.count < passcodeLength {
            passcode += "\(value)"
        }
    }
    
    func onRemoveValue() {
        if !passcode.isEmpty{
            passcode.removeLast()
        }
    }
    
    func onDissmis() {
        withAnimation {
            hideNumberPad = true
        }
    }
    
    func showNumPad() {
        withAnimation {
            hideNumberPad = false
        }
    }
    
    func resetAuthenticationState() {
        passcode = ""
        hideNumberPad = true
        isUnlocked = false
        authenticator.isAuthenticated = false
    }
    
}
