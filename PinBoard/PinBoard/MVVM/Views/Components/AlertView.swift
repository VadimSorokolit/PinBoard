//
//  AlertView.swift
//  PinBoard
//
//  Created by Vadim Sorokolit on 04.08.2025.
//

import SwiftUI

struct AppAlertType: Identifiable {
    
    enum AlertCategory {
        case error
        case info
        case warning
        case complete
        
        var titleColor: Color {
            switch self {
                case .error:
                    return .red
                case .warning:
                    return .orange
                case .info:
                    return .blue
                case .complete:
                    return .green
            }
        }
        
        var titleIcon: String {
            switch self {
                case .error:
                    return "xmark.octagon.fill"
                case .warning:
                    return "exclamationmark.triangle.fill"
                case .info:
                    return "info.circle.fill"
                case .complete:
                    return "checkmark.circle.fill"
            }
        }
    }
    
    let id = UUID()
    let type: AlertCategory
    let message: Text
    let onConfirm: () -> Void
    let onCancel: (() -> Void)?
    
    init(
        type: AlertCategory,
        message: Text,
        onConfirm: @escaping () -> Void,
        onCancel: (() -> Void)? = nil
    ) {
        self.type = type
        self.message = message
        self.onConfirm = onConfirm
        self.onCancel = onCancel
    }
}

enum Alert {
    
    struct Key: EnvironmentKey {
        static let defaultValue: Binding<AppAlertType?> = .constant(nil)
    }
    
    struct AlertOverlayModifier: ViewModifier {
        @Binding var type: AppAlertType?
        
        func body(content: Content) -> some View {
            ZStack {
                content
                if let alert = type {
                    Color.black.opacity(0.25)
                        .ignoresSafeArea()
                    
                    VStack(spacing: .zero) {
                        Image(systemName: alert.type.titleIcon)
                            .font(.system(size: 40.0, weight: .semibold))
                            .foregroundStyle(alert.type.titleColor)
                            .padding(.top, 16.0)
                        
                        alert.message
                            .font(.custom(GlobalConstants.regularFont, size: 16.0))
                            .multilineTextAlignment(.center)
                            .lineSpacing(6.0)
                            .lineLimit(3)
                            .foregroundStyle(.primary)
                            .padding(.top, 16.0)
                            .padding(.bottom, 18.0)
                            .padding(.horizontal, 16.0)
                        
                        Divider()
                            .frame(maxWidth: .infinity)
                        
                        if let cancel = alert.onCancel {
                            HStack {
                                Button(action: {
                                    type = nil
                                    cancel()
                                }) {
                                    Text("Cancel")
                                        .font(.custom(GlobalConstants.mediumFont, size: 16.0))
                                        .frame(maxWidth: .infinity, minHeight: 44.0)
                                        .contentShape(Rectangle())
                                }
                                
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 0.5)
                                
                                Button(action: {
                                    let action = alert.onConfirm
                                    type = nil
                                    action()
                                }) {
                                    Text("Submit")
                                        .font(.custom(GlobalConstants.semiBoldFont, size: 16.0))
                                        .frame(maxWidth: .infinity, minHeight: 44.0)
                                        .contentShape(Rectangle())
                                }
                            }
                            .background(alert.type.titleColor.opacity(0.05))
                        } else {
                            Button(action: {
                                let action = alert.onConfirm
                                type = nil
                                action()
                            }) {
                                Text("OK")
                                    .font(.custom(GlobalConstants.mediumFont, size: 16.0))
                                    .frame(maxWidth: .infinity, minHeight: 44.0)
                                    .contentShape(Rectangle())
                                    .background(alert.type.titleColor.opacity(0.05))
                            }
                        }
                    }
                    .frame(maxWidth: 300.0)
                    .fixedSize(horizontal: false, vertical: true)
                    .background(Color(hex: 0xEFF1F1))
                    .clipShape(RoundedRectangle(cornerRadius: 20.0, style: .continuous))
                    .shadow(color: .black.opacity(0.2), radius: 20.0, x: 0.0, y: 10.0)
                    .transition(.scale.combined(with: .opacity))
                    .animation(.spring(response: 0.35, dampingFraction: 0.88), value: type != nil)
                }
            }
        }
    }
}
