//
//  PinBoardViewModel.swift
//  PinBoard
//
//  Created by Vadim Sorokolit on 08.07.2025.
//

import SwiftUI

@Observable
class PinBoardViewModel {

    // MARK: - Properties. Public
    
    var passcode = ""
    var isUnlocked: Bool {
      get { authenticator.isAuthenticated }
      set { authenticator.isAuthenticated = newValue }
    }
    var hideNumberPad: Bool = true
    
    let authenticator: Authenticator
    private let dataStorage: LocalStorage
    
    // MARK: - Inititializer

    init(authenticator: Authenticator, dataStorage: LocalStorage) {
        self.authenticator = authenticator
        self.dataStorage = dataStorage
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
        withAnimation {
            self.hideNumberPad = true
        }
    }
    
    func showNumPad() {
        withAnimation {
            self.hideNumberPad = false
        }
    }
    
    func resetAuthenticationState() {
        self.passcode = ""
        self.hideNumberPad = true
        self.isUnlocked = false
        self.authenticator.isAuthenticated = false
    }
    
}
