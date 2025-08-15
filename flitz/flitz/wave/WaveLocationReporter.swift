//
//  WaveLocationReporter.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/15/25.
//

import Foundation

import CoreLocation

class WaveLocationReporter: NSObject {
    static let shared = WaveLocationReporter()
    
    let locationManager = CLLocationManager()
    
    weak var client: FZAPIClient? = nil
    
    private let logger = createFZOSLogger("WaveLocationReporter")
    
    var location: CLLocation? {
        locationManager.location
    }
    
    override init() {
        super.init()

        locationManager.delegate = self
    }
    
    func startMonitoring() {
        let constraint = CLBeaconIdentityConstraint(uuid: UUID(uuidString: FlitzWaveServiceID.default.rawValue.uuidString)!)
        
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.startRangingBeacons(satisfying: constraint)
    }
    
    func stopMonitoring() {
        self.locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    func requestLocation() {
        self.locationManager.requestLocation()
    }
    
    func postLocation(_ location: CLLocation) async throws {
        guard let client = self.client else {
            return
        }
        
        let args = WaveUpdateLocationArgs(latitude: location.coordinate.latitude,
                                          longitude: location.coordinate.longitude,
                                          altitude: location.altitude,
                                          accuracy: location.horizontalAccuracy)
        
        try await client.waveUpdateLocation(args)
    }
}

extension WaveLocationReporter: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            
        case .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()
            
        case .restricted, .denied:
            break
            
        case .authorizedAlways:
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.showsBackgroundLocationIndicator = true
            locationManager.pausesLocationUpdatesAutomatically = false
            break
            
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        
        Task {
            do {
                try await postLocation(location)
            } catch {
                logger.error("Failed to post location: \(error)")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        logger.error("Location manager failed with error: \(error)")
    }
}
