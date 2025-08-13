//
//  ColorGradient.swift
//  PinBoard
//
//  Created by Vadim Sorokolit on 04.08.2025.
//
    
import SwiftUI

struct ColorGradient: Identifiable, Equatable {
    
    // MARK: - Properties. Private
    
    private let colorValues: [Color]
    
    // MARK: - Properties. Public
    
    let id = UUID()
    var gradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: colorValues),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    static let palette: [ColorGradient] = [
        .init([.green, .mint]),
        .init([.blue, .cyan]),
        .init([.yellow, .brown]),
        .init([.purple, .pink]),
        .init([.gray, .black]),
    ]
    
    // MARK: - Initializer
    
    private init(_ colors: [Color]) {
        self.colorValues = colors
    }
    
}
