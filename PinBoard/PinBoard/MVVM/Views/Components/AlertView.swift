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
    
    init(
        message: Text,
        okTitle: String = "OK",
        onOk: @escaping () -> Void
    ) {
        self.message = message
        self.confirmTitle = okTitle
        self.cancelTitle = nil
        self.onConfirm = onOk
        self.onCancel = nil
    }
    
    init(
        message: Text,
        confirmTitle: String = "Add",
        cancelTitle: String = "Cancel",
        onConfirm: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.message = message
        self.confirmTitle = confirmTitle
        self.cancelTitle = cancelTitle
        self.onConfirm = onConfirm
        self.onCancel = onCancel
    }
    
    var body: some View {
        ZStack {
            Color(hex: 0xEFEFF0).opacity(0.01).ignoresSafeArea()
            
            VStack(spacing: .zero) {
                message
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                    .lineSpacing(6.0)
                    .padding(.horizontal, 16.0)
                    .padding(.vertical, 12.0)
                
                Divider()
                
                if let cancel = cancelTitle, let onCancel = onCancel {
                    HStack(spacing: 0) {
                        Button(cancel, action: onCancel)
                            .frame(maxWidth: .infinity, minHeight: 44.0)
                            .font(.custom(GlobalConstants.regularFont, size: 16.0))
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 0.5)
                        Button(confirmTitle, action: onConfirm)
                            .frame(maxWidth: .infinity, minHeight: 44.0)
                            .font(.custom(GlobalConstants.semiBoldFont, size: 16.0))
                    }
                } else {
                    Button(confirmTitle, action: onConfirm)
                        .frame(maxWidth: .infinity, minHeight: 44.0)
                        .font(.custom(GlobalConstants.mediumFont, size: 16.0))
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
