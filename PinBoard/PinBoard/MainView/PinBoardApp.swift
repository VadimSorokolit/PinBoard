//
//  PinBoardApp.swift
//  PinBoard
//
//  Created by Vadim Sorokolit on 07.07.2025.
//

import Foundation
import SwiftUI
import SwiftData

@main
struct PinBoardApp: App {
    
    // MARK: - Properties. Private
    
    @State private var viewModel: PinBoardViewModel
    @State private var isOverlayShown: Bool = false
    @AppStorage(GlobalConstants.userDefaultPasscodeKey) private var passcode: String?
    private let sharedModelContainer: ModelContainer
    
    // MARK: - Initializer
    
    init() {
        let schema = Schema([StorageLocation.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            self.sharedModelContainer = container
            
            let authenticator = Authenticator()
            let networkService = NetworkService()
            let viewModel = PinBoardViewModel(authenticator: authenticator, networkService: networkService)
            
            self.viewModel = viewModel
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    // MARK: - Root Scene
    
    var body: some Scene {
        WindowGroup {
            Group {
                if viewModel.isAuthenticated {
                    ZStack {
                        HomeView()
                            .modelContainer(sharedModelContainer)
                        
                        if isOverlayShown {
                            Color.white
                                .edgesIgnoringSafeArea(.all)
                        }
                    }
                    // Need to fix Tab Bar animation
                    .onAppear() {
                        isOverlayShown = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            isOverlayShown = false
                        }
                    }
                } else if passcode != nil {
                    SignInView()
                } else {
                    SignUpView()
                }
            }
            .statusBar(hidden: true)
            .environment(viewModel)
        }
    }
    
}
