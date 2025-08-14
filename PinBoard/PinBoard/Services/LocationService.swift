//
//  LocationService.swift
//  PinBoard
//
//  Created by Vadim Sorokolit on 04.08.2025.
//

import CoreLocation

protocol LocationServiceProtocol: AnyObject {
    var delegate: CLLocationManagerDelegate? { get set }
    var authorizationStatus: CLAuthorizationStatus { get }
    var location: CLLocation? { get }
    func requestWhenInUseAuthorization()
    func requestLocation()
}

class LocationService: NSObject, CLLocationManagerDelegate {
    
    // MARK: - Properties. Private
    
    private let service: LocationServiceProtocol
    private var locationContinuation: CheckedContinuation<CLLocationCoordinate2D, Never>?
    private static let fallbackCoordinate = CLLocationCoordinate2D(latitude: 50.4501, longitude: 30.5234)
    
    // MARK: - Initializer
    
    init(service: LocationServiceProtocol = CLLocationManager()) {
        self.service = service
        super.init()
        self.service.delegate = self
    }
    
    // MARK: - Methods. Public
    
    func requestLocation() async -> CLLocationCoordinate2D {
        if service.authorizationStatus == .notDetermined {
            service.requestWhenInUseAuthorization()
        }
        if let cached = service.location?.coordinate { return cached }
        
        return await withCheckedContinuation { continuation in
            self.locationContinuation = continuation
            self.service.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let coordinate = locations.last?.coordinate ?? Self.fallbackCoordinate
        
        self.locationContinuation?.resume(returning: coordinate)
        self.locationContinuation = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.locationContinuation?.resume(returning: Self.fallbackCoordinate)
        self.locationContinuation = nil
    }
    
}
