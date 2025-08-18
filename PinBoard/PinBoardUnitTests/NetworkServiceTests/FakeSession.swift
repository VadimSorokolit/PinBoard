//
//  FakeSession.swift
//  PinBoard
//
//  Created by Vadim Sorokolit on 14.08.2025.
//

import Foundation
import Testing
@testable import PinBoard

final class FakeSession: URLSessionProtocol {
    
    // MARK: - Properties. Private
    
    private var nextData: Data
    private var nextResponse: URLResponse
    private var nextError: Error?
    
    // MARK: - Properties. Public
    
    private(set) var lastRequestedURL: URL?
    
    // MARK: - Initializer
    
    init(data: Data, response: URLResponse, error: Error? = nil) {
        self.nextData = data
        self.nextResponse = response
        self.nextError = error
    }
    
    // MARK: - Methods. Public
    
    func data(from url: URL) async throws -> (Data, URLResponse) {
        self.lastRequestedURL = url
        
        if let error = nextError {
            throw error
        }
        
        return (self.nextData, self.nextResponse)
    }
    
}
