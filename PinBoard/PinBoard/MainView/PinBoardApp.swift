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
struct PinBoardApp: App, AuthenticatorDelegate {
    
    // MARK: - Properties. Private
    
    @State private var viewModel: PinBoardViewModel
    @State private var appAlert: AppAlertType?
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
            authenticator.delegate = self
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
            .modifier(LoadViewModifier(viewModel: $viewModel, appAlert: $appAlert))
        }
    }
    
    // MARK: - Methods. Public
    
    func authenticator(_ authenticator: any AuthenticatorProtocol, didFailWith message: String) {
        Task { @MainActor in
            appAlert = .init(
                type: .error,
                message: Text(message),
                onConfirm: {}
            )
        }
    }
    
    // MARK: - Modifiers
    
    private struct LoadViewModifier: ViewModifier {
        @Binding var viewModel: PinBoardViewModel
        @Binding var appAlert: AppAlertType?
        
        func body(content: Content) -> some View {
            content
                .statusBar(hidden: true)
                .environment(viewModel)
                .environmentAlert($appAlert)
                .task { [appAlertBinding = $appAlert] in
                    AESEncryptionService.onError = { message in
                        Task { @MainActor in
                            appAlertBinding.wrappedValue = .init(
                                type: .error,
                                message: Text(message),
                                onConfirm: {}
                            )
                        }
                    }
                }
        }
    }
}
