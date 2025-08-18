//
//  StorageLocation.swift
//  PinBoard
//
//  Created by Vadim Sorokolit on 09.07.2025.
//

import Foundation
import SwiftData

@Model
final class StorageLocation: Identifiable {
    
    // MARK: - Properties
    
    @Attribute(.unique) var id: String = UUID().uuidString
    var index:Int
    var name: String
    var longitude: Double
    var latitude: Double
    
    // MARK: - Initializer
    
    init(
        index:Int = 1,
        name: String = "",
        longitude: Double = 0.0,
        latitude: Double = 0.0
    ) {
        self.index = index
        self.name = name
        self.longitude = longitude
        self.latitude  = latitude
    }
    
}
