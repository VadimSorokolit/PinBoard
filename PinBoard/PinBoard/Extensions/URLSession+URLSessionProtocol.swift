//
//  URLSession+URLSessionProtocol.swift
//  PinBoard
//
//  Created by Vadim Sorokolit on 14.08.2025.
//
    
import Foundation

protocol URLSessionProtocol {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}
