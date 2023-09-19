//
//  LocationManager.swift
//  Weather_Challenge
//
//  Created by Vladislav on 9/19/23.
//

import Foundation
import Combine
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared: LocationManager = LocationManager()
    
    private let locationManager = CLLocationManager()
    let objectWillChange = PassthroughSubject<Void, Never>()

    @Published var location: CLLocation? {
        willSet { objectWillChange.send() }
    }
    
    private var locationAccess = false

    private override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
       
    }

    func requestLocation() {
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    func checkLocationAuthorizationStatus() -> Bool {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            locationAccess = true
            return locationAccess
        case .restricted, .notDetermined, .denied:
            locationAccess = false
            return locationAccess
        @unknown default:
            return false
        }
    }
}
