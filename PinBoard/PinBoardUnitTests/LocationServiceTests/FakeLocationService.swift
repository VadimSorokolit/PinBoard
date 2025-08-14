//
//  FakeLocationManager.swift
//  PinBoard
//
//  Created by Vadim Sorokolit on 14.08.2025.
//

import Foundation
import CoreLocation
import Testing
@testable import PinBoard

final class FakeLocationService: LocationServiceProtocol {
    
    // MARK: - Properties. Public
    
    weak var delegate: CLLocationManagerDelegate?
    var authorizationStatus: CLAuthorizationStatus = .authorizedWhenInUse
    var location: CLLocation? = nil
    var testCoordinate = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    var shouldFail = false
    
    // MARK: - Methods. Public
    
    func requestWhenInUseAuthorization() {}
    
    func requestLocation() {
        if self.shouldFail {
            self.delegate?.locationManager?(
                CLLocationManager(),
                didFailWithError: NSError(domain: "Test", code: 1)
            )
        } else {
            let location = CLLocation(latitude: self.testCoordinate.latitude,
                                      longitude: self.testCoordinate.longitude)
            self.delegate?.locationManager?(
                CLLocationManager(),
                didUpdateLocations: [location]
            )
        }
    }
    
}
