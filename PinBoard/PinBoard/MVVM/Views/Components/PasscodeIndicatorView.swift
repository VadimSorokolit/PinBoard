//
//  PasscodeIndicatorView.swift
//  PinBoard
//
//  Created by Vadim Sorokolit on 08.07.2025.
//
    
import SwiftUI

struct PasscodeIndicatorView: View {
    @Environment(PinBoardViewModel.self) var viewModel
    @Environment(\.colorScheme) var colorScheme
    let isWrongPassword: Bool
    private var baseColor: Color { .red }
    private var strokeColor: Color {
        isWrongPassword
        ? .red
        : (colorScheme == .dark ? .white : .black)
    }
    
    var body: some View {
        HStack(spacing: 32.0) {
            ForEach(.zero ..< GlobalConstants.passcodeLength, id: \.self) { index in
                Circle()
                    .fill(baseColor.opacity(isWrongPassword ? 1.0 : 0.0))
                    .background(
                        
                        Circle()
                            .fill(
                                !isWrongPassword && (viewModel.passcode.count > index)
                                ? Color.primary
                                : Color.clear
                            )
                    )
                    .frame(width: 20.0, height: 20.0)
                    .overlay(
                        Circle()
                            .stroke(strokeColor, lineWidth: 1.0)
                    )
                    .animation(.easeOut(duration: 0.5), value: isWrongPassword)
            }
        }
    }
    
}
