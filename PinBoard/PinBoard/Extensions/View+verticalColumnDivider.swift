//
//  View+verticalColumnDivider.swift
//  PinBoard
//
//  Created by Vadim Sorokolit on 16.07.2025.
//

import Foundation
import SwiftUI

extension View {
    
    func verticalColumnDivider(color: Color = .gray.opacity(0.3),width: CGFloat = 1.0) -> some View {
        self.overlay(
            Rectangle()
                .frame(width: width)
                .foregroundColor(color)
                .offset(x: GlobalConstants.gridHorizontalSpacing / 2.0),
            alignment: .trailing
        )
    }
    
}
