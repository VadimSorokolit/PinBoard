//
//  AlertView.swift
//  PinBoard
//
//  Created by Vadim Sorokolit on 04.08.2025.
//

import SwiftUI

struct AlertView: View {
    enum Layout {
        case informational, confirmation
    }
    
    let message: Text
    let layout: Layout
    let confirmTitle: String
    let cancelTitle: String?
    let onConfirm: () -> Void
    let onCancel: (() -> Void)?
    
    init(message: Text,
         layout: Layout,
         onConfirm: @escaping () -> Void,
         onCancel: (() -> Void)? = nil) {
        
        self.message = message
        self.layout = layout
        self.onConfirm = onConfirm
        self.onCancel = onCancel
        
        switch layout {
            case .informational:
                self.confirmTitle = "OK"
                self.cancelTitle = nil
            case .confirmation:
                self.confirmTitle = "Add"
                self.cancelTitle = "Cancel"
        }
    }
    
    var body: some View {
        ZStack {
            Color(hex: 0xEFEFF0).opacity(0.01).ignoresSafeArea()
            
            VStack(spacing: .zero) {
                message
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                    .font(.custom(GlobalConstants.regularFont, size: 16.0))
                    .lineSpacing(6.0)
                    .padding(.horizontal, 16.0)
                    .padding(.vertical, 12.0)
                
                Divider()
                
                switch layout {
                    case .informational:
                        Button(confirmTitle) {
                            onConfirm()
                        }
                        .frame(maxWidth: .infinity, minHeight: 44.0)
                        .font(.custom(GlobalConstants.mediumFont, size: 16.0))
                        
                    case .confirmation:
                        HStack(spacing: .zero) {
                            Button(cancelTitle ?? "Cancel") {
                                onCancel?()
                            }
                            .frame(maxWidth: .infinity, minHeight: 44.0)
                            .font(.custom(GlobalConstants.mediumFont, size: 16.0))
                            
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 0.5)
                            
                            Button(confirmTitle) {
                                onConfirm()
                            }
                            .frame(maxWidth: .infinity, minHeight: 44.0)
                            .font(.custom(GlobalConstants.semiBoldFont, size: 16.0))
                        }
                }
            }
            .background(Color.white)
            .cornerRadius(13.0)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: 270.0)
            .shadow(radius: 20.0)
        }
        .transition(.opacity.combined(with: .scale))
    }
}
