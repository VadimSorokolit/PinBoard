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

    var selectedLocation: StorageLocation? = nil
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
    var passcode = ""
    var hideNumberPad: Bool = true
    var isLoading: Bool = false
    
    // MARK: - Properties. Private
    
    private let authenticator: AuthenticatorProtocol
    private let networkService: NetworkServiceProtocol
    
    // MARK: - Inititializer
    
    init(authenticator: AuthenticatorProtocol, networkService: NetworkServiceProtocol) {
        self.authenticator = authenticator
        self.networkService = networkService
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
    
    func loadLocation(for latitude: Double, longitude: Double) async -> Location? {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let location = try await networkService.fetchLocation(lat: latitude, lon: longitude)
            return location
        } catch let error as URLError {
            if case URLError.badServerResponse = error {
                print("Server error")
            } else {
                print(error.localizedDescription)
            }
        } catch {
            print("Error: Unexpected error")
        }
        
        return nil
    }
    
}
