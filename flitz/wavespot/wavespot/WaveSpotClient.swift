//
//  WaveSpotClient.swift
//  Flitz
//
//  Created by Gyuhwan Park on 9/13/25.
//

import Foundation

import CoreLocation
import CoreBluetooth

protocol WaveSpotClientDelegate: AnyObject {
    func waveSpotClientDidRequestLocationPermission(_ client: WaveSpotClient)
    
    func waveSpotClientDidAuthorize(_ client: WaveSpotClient, token: String)
    func waveSpotClient(_ client: WaveSpotClient, didFailWithError error: Error)
}

class WaveSpotClient: NSObject {
#if DEBUG
    static let BEACON_UUID = UUID(uuidString: "88694848-9383-4544-BD6E-5F9969DACCEA")!
#else
    static let BEACON_UUID = UUID(uuidString: "2ADF31E0-FF0E-4947-84E5-EA21F718AB4E")!
#endif
    
    let logger = createFZOSLogger("WaveSpotClient")
    
    let locationManager = CLLocationManager()
    let constraint = CLBeaconIdentityConstraint(uuid: BEACON_UUID)

    weak var delegate: WaveSpotClientDelegate? = nil
    
    private var currentLocation: CLLocation? = nil {
        didSet {
            self.authorize()
        }
    }
    private var discoveredBeacon: (UInt16, UInt16)? = nil {
        didSet {
            self.authorize()
        }
    }
    
    private var authorizationTask: Task<Void, Error>? = nil
    
    override init() {
        super.init()
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.delegate = self
    }
    
    func bootstrap() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func authorize() {
        guard let location = self.currentLocation,
              let beacon = self.discoveredBeacon
        else {
            logger.warning("Cannot authorize without location or discovered beacon.")
            return
        }
        
        if authorizationTask == nil {
            authorizationTask = Task {
                do {
                    try await authorizeInner(location: location, beacon: beacon)
                } catch {
                    logger.error("Authorization failed: \(error.localizedDescription)")
                    self.delegate?.waveSpotClient(self, didFailWithError: error)
                }
                authorizationTask = nil
            }
        } else {
            logger.info("Authorization already in progress.")
        }
    }
    
    @MainActor
    private func authorizeInner(location: CLLocation, beacon: (UInt16, UInt16)) async throws {
        // TODO: implement this
    }
    
    private func startScanning() {
        locationManager.requestLocation()
        locationManager.startRangingBeacons(satisfying: constraint)
        
        logger.info("Started scanning for beacons.")
    }
    
    private func stopScanning() {
        logger.info("Stopped scanning for beacons.")
        locationManager.stopRangingBeacons(satisfying: constraint)
    }
}

extension WaveSpotClient: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            logger.warning("Location access is restricted or denied.")
            self.delegate?.waveSpotClientDidRequestLocationPermission(self)
        case .authorizedAlways, .authorizedWhenInUse:
            logger.info("Location access granted.")
            self.startScanning()
        @unknown default:
            logger.error("Unknown authorization status.")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            logger.info("Updated location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            self.currentLocation = locations.last
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        
        guard let nearestBeacon = beacons.first else {
            logger.info("No beacons found.")
            return
        }
        
        let major = nearestBeacon.major.uint16Value
        let minor = nearestBeacon.minor.uint16Value
        
        if discoveredBeacon?.0 != major || discoveredBeacon?.1 != minor {
            discoveredBeacon = (major, minor)
            logger.info("Discovered beacon - Major: \(major), Minor: \(minor), Proximity: \(nearestBeacon.proximity.rawValue), RSSI: \(nearestBeacon.rssi)")
        }
    }
}

