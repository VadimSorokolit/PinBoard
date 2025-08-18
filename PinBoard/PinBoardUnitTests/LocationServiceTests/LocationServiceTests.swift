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
        let testLocationLatitude: Double = 10.0
        let testLocationLongitude: Double = 20.0
        
        let fakeLocationService = FakeLocationService()
        fakeLocationService.authorizationStatus = .authorizedWhenInUse
        fakeLocationService.location = CLLocation(latitude: testLocationLatitude, longitude: testLocationLongitude)
        
        let testedService = LocationService(service: fakeLocationService)
        let coordinate = await testedService.requestLocation()
        
        #expect(coordinate.latitude == testLocationLatitude)
        #expect(coordinate.longitude == testLocationLongitude)
    }
    
    @Test
    func testReturnCoordinateFromDelegate() async {
        let testLocationLatitude: Double = 48.45
        let testLocationLongitude: Double = 34.98
        
        let fakeService = FakeLocationService()
        fakeService.authorizationStatus = .authorizedWhenInUse
        fakeService.location = nil
        
        fakeService.testCoordinate = .init(latitude: testLocationLatitude, longitude: testLocationLongitude)
        
        let testedService = LocationService(service: fakeService)
        let coordinate = await testedService.requestLocation()
        
        #expect(coordinate.latitude == testLocationLatitude)
        #expect(coordinate.longitude == testLocationLongitude)
    }
    
    @Test
    func testReturnDefaultCoordinateOnError() async {
        let defaultCooridateLatitude: Double = 50.4501
        let defaultCooridateLongitude: Double = 30.5234
        let fakeService = FakeLocationService()
        
        fakeService.authorizationStatus = .authorizedWhenInUse
        fakeService.location = nil
        fakeService.shouldFail = true
        
        let testedService = LocationService(service: fakeService)
        let coordinate = await testedService.requestLocation()
        
        #expect(coordinate.latitude == defaultCooridateLatitude)
        #expect(coordinate.longitude == defaultCooridateLongitude)
    }
    
    @Test
    func testHandlesSequentialRequests() async {
        let testLocationLongitude: Double = 1.0
        let testLocationLatitude: Double = 2.0
        let newTestLocationLatitude: Double = 3.0
        let newTestLocationLongitude: Double = 4.0
        
        let fakeService = FakeLocationService()
        fakeService.authorizationStatus = .authorizedWhenInUse
        fakeService.location = nil
        
        let testedService = LocationService(service: fakeService)
        
        fakeService.testCoordinate = .init(latitude: testLocationLatitude, longitude: testLocationLongitude)
        let firstRequest = await testedService.requestLocation()
        
        #expect(firstRequest.latitude == testLocationLatitude)
        #expect(firstRequest.longitude == testLocationLongitude)
        
        fakeService.testCoordinate = .init(latitude: newTestLocationLatitude, longitude: newTestLocationLongitude)
        let secondRequest = await testedService.requestLocation()
        
        #expect(secondRequest.latitude == newTestLocationLatitude)
        #expect(secondRequest.longitude == newTestLocationLongitude)
    }
    
}
