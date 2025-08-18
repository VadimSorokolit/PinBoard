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
    func testEncryptAndDecryptReturnsOriginal() throws {
        let text = "Hello world"
        let key = "my-secret-key"
        
        if let encrypted = AESEncryptionService.encrypt(plainText: text, key: key) {
            let decrypted = AESEncryptionService.decrypt(encryptedText: encrypted, key: key)
            
            #expect(decrypted == text)
        }
    }
    
    @Test
    func testVerifyDecryptFailsWithInvalidKey()  throws {
        let text = "Top secret"
        let key = "correct-key"
        let wrongKey = "wrong-key"
        
        if let encrypted = AESEncryptionService.encrypt(plainText: text, key: key) {
            let result = AESEncryptionService.decrypt(encryptedText: encrypted, key: wrongKey)
            
            #expect(result == nil)
        }
    }
    
    @Test
    func testCheckEncryptDecryptWithEmptyPlainText() throws {
        let text = ""
        let key = "any-key"
        
        if let encrypted = AESEncryptionService.encrypt(plainText: text, key: key) {
            let decrypted = AESEncryptionService.decrypt(encryptedText: encrypted, key: key)
            
            #expect(decrypted == "")
        }
    }
    
    @Test
    func testVerifyInvalidBase64FailsDecryption() throws {
        let key = "any-key"
        let notBase64 = "***not-base64***"
        
        let result = AESEncryptionService.decrypt(encryptedText: notBase64, key: key)
        
        #expect(result == nil)
    }
    
    @Test
    func testVerifyShortKeyEncryptionDecryption() throws {
        let text = "Short key test"
        let shortKey = "abc"
        
        if let encrypted = AESEncryptionService.encrypt(plainText: text, key: shortKey) {
            let decrypted = AESEncryptionService.decrypt(encryptedText: encrypted, key: shortKey)
            
            #expect(decrypted == text)
        }
    }
    
    @Test
    func testVerifyLongKeyEncryptionDecryption()  throws {
        let text = "Long key test"
        let longKey = String(repeating: "x", count: 100)
        
        
        if let encrypted = AESEncryptionService.encrypt(plainText: text, key: longKey) {
            let decrypted = AESEncryptionService.decrypt(encryptedText: encrypted, key: longKey)
            
            #expect(decrypted == text)
        }
    }
    
}
