//
//  View+toast.swift
//  PinBoard
//
//  Created by Vadim Sorokolit on 04.08.2025.
//
    
extension View {
    
    func toast(_ toast: Binding<Toast?>) -> some View {
        self.modifier(ToastModifier(toast: toast))
    }
    
}
