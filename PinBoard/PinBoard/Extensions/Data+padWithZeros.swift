//
//  Data+padWithZeros.swift
//  PinBoard
//
//  Created by Vadim Sorokolit on 07.07.2025.
//

import Foundation

extension Data {
    
    func padWithZeros(targetSize: Int) -> Data {
        var paddedData = self
        
        // Get the current size (number of bytes) of the data
        let dataSize = self.count
        
        // Check if padding is needed
        if dataSize < targetSize {
            
            // Calculate the amount of padding required
            let paddingSize = targetSize - dataSize
            
            // Create padding data filled with zeros
            let padding = Data(repeating: 0, count: paddingSize)
            
            // Append the padding to the original data
            paddedData.append(padding)
        }
        return paddedData
    }
    
}


