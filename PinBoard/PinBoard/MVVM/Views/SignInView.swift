//
//  SignInView.swift
//  PinBoard
//
//  Created by Vadim Sorokolit on 08.07.2025.
//
    
import SwiftUI

struct SignInView: View {
    
    // MARK: - Properties. Private
    
    @Environment(PinBoardViewModel.self) private var viewModel
    @State private var isWrongPassword:Bool = false
    
    // MARK: - Main body
    
    var body: some View {
        PasscodeTemplateView(isWrongPassword: $isWrongPassword, title: "Enter", titleText: "for Sign In", onComplete: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                let success = viewModel.verifyPasscode()
                
                if !success {
                    isWrongPassword = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isWrongPassword = false
                        viewModel.passcode = ""
                    }
                } else {
                    viewModel.passcode = ""
                }
            }
        }) {
            VStack {
                HStack(spacing: 20.0) {
                    if !viewModel.isBiometricLocked {
                        if viewModel.biometryType == .faceID {
                            
                            Button(action: {
                                viewModel.unlockWithFaceId() }) {
                                    Image(systemName: "faceid")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 40.0)
                                }
                        }
                        if viewModel.biometryType == .touchID {
                            
                            Button(action: {
                                
                                viewModel.unlockWithFaceId() }) {
                                    Image(systemName: "touchid")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 40.0)
                                }
                        }
                    }
                    
                    Button(action: {
                        
                        withAnimation {
                            viewModel.showNumPad()
                        }
                    }) {
                        Image(systemName: "keyboard")
                            .font(.title)
                            .padding(.vertical, 16.0)
                            .contentShape(Rectangle())
                    }
                }
                if !viewModel.hideNumberPad {
                    NumberPadView(
                        onAdd: viewModel.onAddValue,
                        onRemoveLast: viewModel.onRemoveValue,
                        onDissmis: viewModel.onDissmis
                    )
                }
            }
        }
    }
    
}
