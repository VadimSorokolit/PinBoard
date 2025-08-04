//
//  LocationService.swift
//  PinBoard
//
//  Created by Vadim Sorokolit on 04.08.2025.
//
    
import CoreLocation

final class LocationService: NSObject, CLLocationManagerDelegate {
    
    // MARK: - Properties. Private
    
    private let manager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<CLLocationCoordinate2D, Never>?
    private static let fallbackCoordinate = CLLocationCoordinate2D(latitude: 50.4501, longitude: 30.5234)
    
    // MARK: - Initializer
    
    override init() {
        super.init()
        
        manager.delegate = self
    }
    
    // MARK: - Methods. Public
    
    func requestLocation() async -> CLLocationCoordinate2D {
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
        if let cached = manager.location?.coordinate {
            return cached
        }
        manager.requestLocation()
        
        return await withCheckedContinuation { continuation in
            self.locationContinuation = continuation
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let coordinate = locations.last?.coordinate ?? Self.fallbackCoordinate
        locationContinuation?.resume(returning: coordinate)
        locationContinuation = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationContinuation?.resume(returning: Self.fallbackCoordinate)
        locationContinuation = nil
    }
    
}
