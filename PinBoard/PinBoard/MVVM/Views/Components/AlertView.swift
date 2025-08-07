//
//  AlertView.swift
//  PinBoard
//
//  Created by Vadim Sorokolit on 04.08.2025.
//
    
import SwiftUI

struct AlertView: View {
    let message: Text
    let confirmTitle: String
    let cancelTitle: String?
    let onConfirm: () -> Void
    let onCancel: (() -> Void)?
    
    var body: some View {
        ZStack {
            Color(hex: 0xEFEFF0).opacity(0.01)
                .ignoresSafeArea()
            
            VStack(spacing: 0.0) {
                message
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                    .lineSpacing(6.0) 
                    .padding(.horizontal, 16.0)
                    .padding(.top, 20.0)
                    .padding(.bottom, 12.0)
                
                Divider()
                
                if let cancelTitle = cancelTitle, let onCancel = onCancel {
                    HStack(spacing: 0.0) {
                        Button(cancelTitle) {
                            onCancel()
                        }
                        .frame(maxWidth: .infinity, minHeight: 44.0)
                        .contentShape(Rectangle())
                        .font(.custom(GlobalConstants.regularFont, size: 16.0))
                        
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 0.5)
                        
                        Button(confirmTitle) {
                            onConfirm()
                        }
                        .frame(maxWidth: .infinity, minHeight: 44.0)
                        .contentShape(Rectangle())
                        .font(.custom(GlobalConstants.mediumFont, size: 16.0))
                    }
                } else {
                    Button(confirmTitle) {
                        onConfirm()
                    }
                    .frame(maxWidth: .infinity, minHeight: 44.0)
                    .contentShape(Rectangle())
                    .font(.custom(GlobalConstants.mediumFont, size: 16.0))
                }
            }
            .background(.white)
            .cornerRadius(13.0)
            .frame(maxWidth: 270.0)
            .fixedSize(horizontal: false, vertical: true)
            .shadow(radius: 20.0)
        }
        .transition(.opacity.combined(with: .scale))
    }
    
}
