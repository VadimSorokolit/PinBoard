//
//  StorageLocation.swift
//  PinBoard
//
//  Created by Vadim Sorokolit on 09.07.2025.
//

import Foundation
import SwiftData

@Model
final class StorageLocation {
    
    // MARK: - Properties
    
    @Attribute(.unique) var id: String
    var name: String
    var longitude: Double
    var latitude: Double
    
    // MARK: - Initializer
    
    init(id: String = UUID().uuidString, name: String = "", longitude: Double = 0.0, latitude: Double  = 0.0) {
        self.id        = id
        self.name      = name
        self.longitude = longitude
        self.latitude  = latitude
    }
}
