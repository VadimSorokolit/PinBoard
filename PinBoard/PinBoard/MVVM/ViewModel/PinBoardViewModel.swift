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
    
    var selectedTab: Tab = .list
    var selectedLocation: StorageLocation? = nil
    var isAuthenticated: Bool {
        get { self.authenticator.isAuthenticated }
        set { self.authenticator.isAuthenticated = newValue }
    }
    var isBiometricLocked: Bool {
        get { self.authenticator.isBiometricLocked }
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
        self.passcode = ""
    }
    
    func verifyPasscode() -> Bool {
        guard self.passcode.count == GlobalConstants.passcodeLength else {
            return false
        }
        let success = self.authenticator.verifyPin(pin: self.passcode)
        
        return success
    }
    
    func logout() {
        self.authenticator.logOut()
    }
    
    func onAddValue(_ value: Int) {
        if self.passcode.count < GlobalConstants.passcodeLength {
            self.passcode += "\(value)"
        }
    }
    
    func onRemoveValue() {
        if self.passcode.isEmpty == false {
            self.passcode.removeLast()
        }
    }
    
    func onDissmis() {
        self.hideNumberPad = true
    }
    
    func showNumPad() {
        self.hideNumberPad = false
    }
    
    func unlockBiometry() {
        self.authenticator.unlockBiometry()
    }
    
    func resetAuthenticationState() {
        self.passcode = ""
        self.hideNumberPad = true
        self.authenticator.isAuthenticated = false
    }
    
    func loadLocation(for latitude: Double, longitude: Double) async throws -> Location? {
        self.isLoading = true
        defer { self.isLoading = false }
        
        do {
            let location = try await self.networkService.fetchLocation(lat: latitude, lon: longitude)
            
            return location
        } catch let urlError as URLError {
            switch urlError.code {
                case .badServerResponse:
                    throw LocationError.server
                case .notConnectedToInternet, .timedOut, .cannotFindHost, .cannotConnectToHost:
                    throw LocationError.network
                default:
                    throw LocationError.unknown(urlError)
            }
        }
    }

}
