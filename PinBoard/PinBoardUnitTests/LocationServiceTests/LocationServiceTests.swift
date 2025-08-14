//
//  LocationServiceTests.swift
//  PinBoard
//
//  Created by Vadim Sorokolit on 14.08.2025.
//
    
import Foundation
import CoreLocation
import Testing
@testable import PinBoard

@Suite(.serialized)
struct LocationServiceTests {
    
    @Test
    func testReturnCachedCoordinate() async {
        let fakeLocationService = FakeLocationService()
        fakeLocationService.authorizationStatus = .authorizedWhenInUse
        fakeLocationService.location = CLLocation(latitude: 10.0, longitude: 20.0)
        
        let testedService = LocationService(service: fakeLocationService)
        let coordinate = await testedService.requestLocation()
        
        #expect(coordinate.latitude == 10.0)
        #expect(coordinate.longitude == 20.0)
    }
    
    @Test
    func testreturnCoordinateFromDelegate() async {
        let fakeService = FakeLocationService()
        fakeService.authorizationStatus = .authorizedWhenInUse
        fakeService.location = nil
        fakeService.testCoordinate = .init(latitude: 48.45, longitude: 34.98)
        
        let testedService = LocationService(service: fakeService)
        let coordinate = await testedService.requestLocation()
        
        #expect(coordinate.latitude == 48.45)
        #expect(coordinate.longitude == 34.98)
    }
    
    @Test
    func testReturnsDefaultCoordinateOnError() async {
        let fakeService = FakeLocationService()
        fakeService.authorizationStatus = .authorizedWhenInUse
        fakeService.location = nil
        fakeService.shouldFail = true
        
        let testedService = LocationService(service: fakeService)
        let coordinate = await testedService.requestLocation()
        
        #expect(coordinate.latitude == 50.4501)
        #expect(coordinate.longitude == 30.5234)
    }
    
    @Test
    func testHandlesSequentialRequests() async {
        let fakeService = FakeLocationService()
        fakeService.authorizationStatus = .authorizedWhenInUse
        fakeService.location = nil
        
        let testedService = LocationService(service: fakeService)
        
        fakeService.testCoordinate = .init(latitude: 1.0, longitude: 2.0)
        let firstRequest = await testedService.requestLocation()
        
        #expect(firstRequest.latitude == 1.0)
        #expect(firstRequest.longitude == 2.0)
        
        fakeService.testCoordinate = .init(latitude: 3.0, longitude: 4.0)
        let secondRequest = await testedService.requestLocation()
        
        #expect(secondRequest.latitude == 3.0)
        #expect(secondRequest.longitude == 4.0)
    }
    
}
