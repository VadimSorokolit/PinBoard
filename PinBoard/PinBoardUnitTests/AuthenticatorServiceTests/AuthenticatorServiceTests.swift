//
//  AuthenticatorServiceTests.swift
//  PinBoard
//
//  Created by Vadim Sorokolit on 14.08.2025.
//

import Foundation
import Testing

@testable import PinBoard
@Test
func testSetPasscodeStoresData() {
    let testPasscode = "1234"
    let uthenticator = Authenticator()
    uthenticator.setPasscodeWith(testPasscode)
    let stored = UserDefaults.standard.value(forKey: GlobalConstants.userDefaultPasscodeKey) as? String
    
    #expect(stored != nil)
}

@Test
func testLogoutResetsState() {
    let authenticator = Authenticator()
    authenticator.isAuthenticated = true
    authenticator.logOut()
    
    #expect(authenticator.isAuthenticated == false)
}
