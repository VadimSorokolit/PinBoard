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
        .init([.red, .orange]),
        .init([.blue, .cyan]),
        .init([.green, .mint]),
        .init([.purple, .pink]),
        .init([.yellow, .brown]),
        .init([.teal, .indigo]),
        .init([.gray, .black]),
        .init([.orange, .mint])
    ]
    
}
