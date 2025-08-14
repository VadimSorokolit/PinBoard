//
//  NetworkServiceTests.swift
//  PinBoard
//
//  Created by Vadim Sorokolit on 14.08.2025.
//

import Foundation
import Testing
@testable import PinBoard

@Suite(.serialized)
struct NetworkServiceTests {
    
    // MARK: - Objects
    
    private struct Constants {
        static let urlString: String = "https://example.com"
        static let json: String = #"[{"name":"London","lat":51.5074,"lon":-0.1278},{"name":"Other","lat":0.0,"lon":0.0}]"#
        static let expectedLocationName: String = "London"
        static let parameterLatitudeName: String = "lat"
        static let parameterLongitudeName: String = "lon"
        static let parameterLimitName: String = "limit"
        static let parameterAPIKeyName: String = "appid"
        static let emptyLocationsJson = "[]"
        static let invalidJson = "{ not json ]"
        static let successStatusCode: Int = 200
        static let invalidStatusCode: Int = 500
        static let nonZeroLatitude: Double = 51.5074
        static let nonZeroLongitude: Double = -0.1278
        static let zeroLatitude: Double = 0.0
        static let zeroLongitude: Double = 0.0
    }
    
    // MARK: - Methods. Private
    
    private func createResponse(statusCode: Int, urlString: String) -> HTTPURLResponse? {
        guard let url = URL(string: urlString) else {
            return nil
        }
        return HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)
    }
    
    // MARK: - Methods. Test
    
    @Test
    func getLocation() async throws {
        let json = Constants.json

        if let sucessResponse = createResponse(statusCode: Constants.successStatusCode, urlString: Constants.urlString) {
            let fakeSession = FakeSession(data: Data(json.utf8), response: sucessResponse)
            let service = NetworkService(session: fakeSession)
            let location = try await service.fetchLocation(lat: Constants.nonZeroLatitude, lon: Constants.nonZeroLongitude)
            
            try #require(location != nil)
            
            #expect(location?.name == Constants.expectedLocationName)
            
            let url = try #require(fakeSession.lastRequestedURL)
            let comps = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
            let items = comps.queryItems ?? []
            
            #expect(items.contains(where: { $0.name == Constants.parameterLatitudeName && $0.value == "\(Constants.nonZeroLatitude)" }))
            #expect(items.contains(where: { $0.name == Constants.parameterLongitudeName && $0.value == "\(Constants.nonZeroLongitude)" }))
            #expect(items.contains(where: { $0.name == Constants.parameterLimitName }))
            #expect(items.contains(where: { $0.name == Constants.parameterAPIKeyName }))
        }
    }
    
    @Test
    func checkFailureOnBadStatus() async {
        if let failureResponse = createResponse(statusCode: Constants.invalidStatusCode, urlString: Constants.urlString) {
            let fakeSession = FakeSession(data: Data(), response: failureResponse)
            let service = NetworkService(session: fakeSession)
            
            await #expect(throws: URLError.self) {
                try await service.fetchLocation(lat: Constants.nonZeroLatitude, lon: Constants.nonZeroLongitude)
            }
        }
    }
    
    @Test
    func verifyInvalidJson() async {
        if let sucessResponse = createResponse(statusCode: Constants.successStatusCode, urlString: Constants.urlString) {
            let fakeSession = FakeSession(data: Data(Constants.invalidJson.utf8), response: sucessResponse)
            let service = NetworkService(session: fakeSession)
            
            await #expect(throws: DecodingError.self) {
                _ = try await service.fetchLocation(lat: Constants.nonZeroLatitude, lon: Constants.nonZeroLongitude)
            }
        }
    }
    
    @Test
    func verifyEmptyArray() async throws {
        if let sucessResponse = createResponse(statusCode: Constants.successStatusCode, urlString: Constants.urlString) {
            let fakeSession = FakeSession(data: Data(Constants.emptyLocationsJson.utf8), response: sucessResponse)
            let service = NetworkService(session: fakeSession)
            
            let location = try await service.fetchLocation(lat: Constants.zeroLatitude, lon: Constants.zeroLongitude)
            
            #expect(location == nil)
        }
    }
        
}
