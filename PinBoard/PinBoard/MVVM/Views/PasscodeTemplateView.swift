//
//  PasscodeTemplateView.swift
//  PinBoard
//
//  Created by Vadim Sorokolit on 08.07.2025.
//
    
import SwiftUI

struct PasscodeTemplateView<Content: View>: View {
    @Environment(PinBoardViewModel.self) var viewModel
    @Binding var isWrongPassword: Bool
    let title: String
    let titleText: String
    let onComplete: () -> Void
    let content: () -> Content

    var body: some View {
        VStack(spacing: 48.0) {
            TitleView(passcodeLength: viewModel.passcodeLength, title: title, titleText: titleText)
            
            PasscodeWithContentView(isWrongPassword: $isWrongPassword, content: content)
        }
        .onChange(of: viewModel.passcode) { oldValue, newValue in
            guard newValue.count == viewModel.passcodeLength else {
                return
            }
            onComplete()
        }
    }
    
    private struct TitleView: View {
        let passcodeLength: Int
        let title: String
        let titleText: String
        
        var body: some View {
            VStack(spacing: 24.0) {
                Text("\(title) Passcode")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                
                Text("Please enter \(passcodeLength)-digit PIN \(titleText)")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
            }
            .padding(.top)
        }
        
    }
    
    private struct PasscodeWithContentView<Inner: View>: View {
        @Binding var isWrongPassword: Bool
        let content: () -> Inner
        
        var body: some View {
            VStack {
                PasscodeIndicatorView(isWrongPassword: isWrongPassword)
                
                Spacer()
                
                content()
            }
        }
        
    }
    
}
