//
//  PinBoardApp.swift
//  PinBoard
//
//  Created by Vadim Sorokolit on 07.07.2025.
//
    
import SwiftUI

@main
struct PinBoardApp: App {
    
    // MARK: - Properties
    
    @State private var viewModel = PinBoardViewModel(authenticator: Authenticator())
    @AppStorage(GlobalConstants.userDefaultPasscodeKey) private var passcode: String?

    // MARK: - Root Scene
    
    var body: some Scene {
        WindowGroup {
            if viewModel.isUnlocked {
                TableView()
            } else if passcode != nil {
                SignInView()
            } else {
                SignUpView()
            }
        }
        .environment(viewModel)
    }
    
}
