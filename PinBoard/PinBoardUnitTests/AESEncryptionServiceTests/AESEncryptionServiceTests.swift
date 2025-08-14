//
//  AESEncryptionServiceTests.swift
//  PinBoard
//
//  Created by Vadim Sorokolit on 14.08.2025.
//
    
import Foundation
import Testing
@testable import PinBoard

@Suite
struct AESEncryptionServiceTests {
    
    @Test
    func encryptAndDecrypt_returnsOriginal() throws {
        let text = "Hello world"
        let key = "my-secret-key"
        
        let encrypted = AESEncryptionService.encrypt(plainText: text, key: key)
        try #require(encrypted != nil)
        
        let decrypted = AESEncryptionService.decrypt(encryptedText: encrypted!, key: key)
        #expect(decrypted == text)
    }
    
    @Test
    func verifyDecryptFailsWithInvalidKey()  throws {
        let text = "Top secret"
        let key = "correct-key"
        let wrongKey = "wrong-key"
        
        let encrypted = AESEncryptionService.encrypt(plainText: text, key: key)
        
        try #require(encrypted != nil)
        
        let result = AESEncryptionService.decrypt(encryptedText: encrypted!, key: wrongKey)
        
        #expect(result == nil)
    }
    
    @Test
    func checkEncryptDecryptWithEmptyPlainText() throws {
        let text = ""
        let key = "any-key"
        
        let encrypted = AESEncryptionService.encrypt(plainText: text, key: key)
        
        try #require(encrypted != nil)
        
        let decrypted = AESEncryptionService.decrypt(encryptedText: encrypted!, key: key)
        
        #expect(decrypted == "")
    }
    
    @Test
    func verifyInvalidBase64FailsDecryption() throws {
        let key = "any-key"
        let notBase64 = "***not-base64***"
        
        let result = AESEncryptionService.decrypt(encryptedText: notBase64, key: key)
        
        #expect(result == nil)
    }
    
    @Test
    func verifyShortKeyEncryptionDecryption() throws {
        let text = "Short key test"
        let shortKey = "abc"
        
        let encrypted = AESEncryptionService.encrypt(plainText: text, key: shortKey)
        
        try #require(encrypted != nil)
        
        let decrypted = AESEncryptionService.decrypt(encryptedText: encrypted!, key: shortKey)
        
        #expect(decrypted == text)
    }
    
    @Test
    func verifyLongKeyEncryptionDecryption()  throws {
        let text = "Long key test"
        let longKey = String(repeating: "x", count: 100)
        
        let encrypted = AESEncryptionService.encrypt(plainText: text, key: longKey)
        
        try #require(encrypted != nil)
        
        let decrypted = AESEncryptionService.decrypt(encryptedText: encrypted!, key: longKey)
        
        #expect(decrypted == text)
    }
    
}
