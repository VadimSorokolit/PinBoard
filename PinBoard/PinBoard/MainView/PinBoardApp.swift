//
//  PinBoardApp.swift
//  PinBoard
//
//  Created by Vadim Sorokolit on 07.07.2025.
//
    
import SwiftUI
import SwiftData

@main
struct PinBoardApp: App {
    
    // MARK: - Properties
    
    @State private var viewModel: PinBoardViewModel
    @AppStorage(GlobalConstants.userDefaultPasscodeKey) private var passcode: String?
    private let sharedModelContainer: ModelContainer
    
    // MARK: - Initializer
    
    init() {
        let schema = Schema([StorageLocation.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            self.sharedModelContainer = container
            
            let context = container.mainContext
            let authenticator = Authenticator()
            let dataStorage = LocalStorage(context: context)
            let viewModel = PinBoardViewModel(authenticator: authenticator, dataStorage: dataStorage)
            
            self.viewModel = viewModel
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    // MARK: - Root Scene
    
    var body: some Scene {
        WindowGroup {
            if viewModel.isUnlocked {
                HomeView()
            } else if passcode != nil {
                SignInView()
            } else {
                SignUpView()
            }
        }
        .environment(viewModel)
        .modelContainer(sharedModelContainer)
    }
    
}
