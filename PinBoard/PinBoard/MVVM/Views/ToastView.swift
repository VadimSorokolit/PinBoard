//
//  ToastView.swift
//  PinBoard
//
//  Created by Vadim Sorokolit on 31.07.2025.
//
    
import SwiftUI

struct Toast: Equatable {
    var message: String
    var duration: Double = 3.5
    var width: Double = .infinity
}

struct ToastView: View {
    let toast: Toast
    
    var body: some View {
        let parts = toast.message.components(separatedBy: "\n")
        
        VStack(alignment: .center, spacing: 4.0) {
            Text(parts[0])
                .font(.custom(GlobalConstants.mediumFont, size: 16.0))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            if parts.count > 1 {
                Text(parts[1])
                    .font(.custom(GlobalConstants.semiBoldFont, size: 16.0))
                    .foregroundColor(Color(hex: 0xcb1397))
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .frame(minWidth: 0.0, maxWidth: toast.width)
        .background(Color(hex: 0x80e3e5))
        .overlay(
            RoundedRectangle(cornerRadius: 8.0)
                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
        )
        .cornerRadius(8.0)
        .padding(.horizontal, 16.0)
    }
    
}

struct ToastModifier: ViewModifier {
    @Binding var toast: Toast?
    @State private var workItem: DispatchWorkItem?
    @State private var show = false
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if let toast = toast {
                    VStack {
                        Spacer()
                        ToastView(toast: toast)
                            .frame(maxWidth: .infinity)
                            .offset(y: show ? 0 : 200)
                            .animation(
                                .spring(response: 0.4, dampingFraction: 0.7),
                                value: show
                            )
                            .padding(.bottom, 16.0)
                    }
                }
            }
            .onChange(of: toast) { oldValue, newToast in
                show = false
                workItem?.cancel()
                guard newToast != nil else {
                    return
                }
                
                DispatchQueue.main.async {
                    show = true
                }
                
                if let duration = newToast?.duration, duration > 0.0 {
                    let task = DispatchWorkItem { hideToast() }
                    workItem = task
                    
                    DispatchQueue.main.asyncAfter(
                        deadline: .now() + duration,
                        execute: task
                    )
                }
            }
    }
    
    private func hideToast() {
        show = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            toast = nil
            workItem?.cancel()
            workItem = nil
        }
    }
    
}

extension View {
    
    func toast(_ toast: Binding<Toast?>) -> some View {
        self.modifier(ToastModifier(toast: toast))
    }
    
}
