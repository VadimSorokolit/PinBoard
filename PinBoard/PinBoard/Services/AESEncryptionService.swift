//
//  AESEncryptionService.swift
//  PinBoard
//
//  Created by Vadim Sorokolit on 07.07.2025.
//
    
import Foundation
import CryptoKit

class AESEncryptionService {
    
    // MARK: - Methods
    
    static func encrypt(plainText: String, key: String, keySize: Int = 32) -> String? {
        guard let data = plainText.data(using: .utf8), let keyData = key.data(using: .utf8)?.prefix(keySize) else {
            return nil
        }
        let symmetricKey = SymmetricKey(data: keyData.padWithZeros(targetSize: keySize))
        do {
            let sealedBox = try AES.GCM.seal(data, using: symmetricKey, nonce: AES.GCM.Nonce()).combined
            return sealedBox?.base64EncodedString() ?? nil
        } catch {
            print("AESEncryption: Encryption failed with error \(error)")
            return nil
        }
    }
    
    static func decrypt(encryptedText: String, key: String, keySize: Int = 32) -> String? {
        guard let combinedData = Data(base64Encoded: encryptedText), let keyData = key.data(using: .utf8)?.prefix(keySize) else {
            return nil
        }
        let symmetricKey = SymmetricKey(data: keyData.padWithZeros(targetSize: keySize))
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: combinedData)
            let decryptedData = try AES.GCM.open(sealedBox, using: symmetricKey)
            return String(data: decryptedData, encoding: .utf8)
        } catch let error {
            print("AESEncryption: Decryption failed with error \(error)")
            return nil
        }
    }
    
}
