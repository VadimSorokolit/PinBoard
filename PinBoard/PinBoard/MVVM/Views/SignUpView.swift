//
//  SignUpView.swift
//  PinBoard
//
//  Created by Vadim Sorokolit on 08.07.2025.
//
    
import SwiftUI

struct SignUpView: View {
    @Environment(PinBoardViewModel.self) private var viewModel
    
    var body: some View {
        PasscodeTemplateView(isWrongPassword: .constant(false), title: "Register", titleText: "for Sign Up", onComplete: {
            viewModel.registerPasscode()
        }) {
            
            NumberPadView(onAdd: viewModel.onAddValue, onRemoveLast: viewModel.onRemoveValue, onDissmis: viewModel.onDissmis)
        }
    }
    
}
