//
//  PinGradient.swift
//  PinBoard
//
//  Created by Vadim Sorokolit on 04.08.2025.
//
    
import SwiftUI

struct PinGradient: Identifiable, Equatable {
    let id = UUID()
    private let colorValues: [Color]
    
    var gradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: colorValues),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private init(_ colors: [Color]) {
        self.colorValues = colors
    }
    
    static let all: [PinGradient] = [
        .init([.green, .mint]),
        .init([.blue, .cyan]),
        .init([.yellow, .brown]),
        .init([.purple, .pink]),
        .init([.gray, .black]),
    ]
    
}
