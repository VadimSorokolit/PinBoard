//
//  Location+asStorageModel.swift
//  PinBoard
//
//  Created by Vadim Sorokolit on 18.07.2025.
//
    
extension Location {
    
    var asStorageModel: StorageLocation {
        let storageLocation = StorageLocation(
            index: 0,
            name: self.name,
            longitude: self.lon,
            latitude: self.lat
        )
        
        return storageLocation
    }
    
}
