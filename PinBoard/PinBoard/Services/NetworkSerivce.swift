//
//  NetworkSerivce.swift
//  PinBoard
//
//  Created by Vadim Sorokolit on 18.07.2025.
//
 
import Foundation

protocol NetworkServiceProtocol: AnyObject {
    func fetchLocation(lat: Double, lon: Double) async throws -> Location?
}

@Observable
class NetworkService: NetworkServiceProtocol {
    
    // MARK: - Objects
    
    private struct Constants {
        static let baseURL: String  = "https://api.openweathermap.org"
        static let reversePath: String = "/geo/1.0/reverse"
        static let apiKey: String = "f3693c0928d03b567396ceb6cbf03e8c"
        static let parameterLatitudeName: String = "lat"
        static let parameterLongitudeName: String = "lon"
        static let parameterLimitName: String = "limit"
        static let parameterAPIKeyName: String = "appid"
        static let parameterLimitValue: Int = 1
    }
    
    // MARK: - Properties. Private
    
    private let session: URLSessionProtocol
    
    // MARK: - Initializer
    
    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    // MARK: - Methods
    
    func fetchLocation(lat: Double, lon: Double) async throws -> Location? {
        var components = URLComponents(string: Constants.baseURL + Constants.reversePath) ?? URLComponents()
        components.queryItems = [
            URLQueryItem(name: Constants.parameterLatitudeName, value: "\(lat)"),
            URLQueryItem(name: Constants.parameterLongitudeName, value: "\(lon)"),
            URLQueryItem(name: Constants.parameterLimitName, value: "\(Constants.parameterLimitValue)"),
            URLQueryItem(name: Constants.parameterAPIKeyName, value: Constants.apiKey)
        ]
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        let (data, response) = try await self.session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
        
        let decoded = try JSONDecoder().decode([Location].self, from: data)
        return decoded.first
    }
    
}
