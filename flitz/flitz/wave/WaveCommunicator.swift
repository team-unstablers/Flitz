//
//  BLECommunicator.swift
//  FlitzCardExchangeTest
//
//  Created by Gyuhwan Park on 12/3/24.
//

import CoreBluetooth
import CoreLocation

protocol WaveCommunicatorDelegate: AnyObject {
    func communicator(_ communicator: WaveCommunicator, didStart sessionId: String)
    func communicator(_ communicator: WaveCommunicator, didStop sessionId: String)
}


@MainActor
class WaveCommunicator {
    var client: FZAPIClient
    
    let locationReporter = WaveLocationReporter.shared
    
    let discoverer: WaveDiscoverer
    let broadcaster: WaveBroadcaster
    
    var identity: String {
        get {
            return broadcaster.identity
        }
        set {
            broadcaster.identity = newValue
        }
    }
    
    weak var delegate: WaveCommunicatorDelegate? = nil
    
    private(set) var isActive: Bool = false
    
    init(with client: FZAPIClient) {
        self.client = client
        
        locationReporter.client = client
        
        discoverer = WaveDiscoverer(locationReporter: locationReporter)
        broadcaster = WaveBroadcaster()
        
        discoverer.delegate = self
        
        if client.context.id != nil {
            locationReporter.startMonitoring()
        }
    }
    
    func start() async throws {
        let session = try await client.startWaveDiscovery()
        self.identity = session.session_id
        
        print("starting wave with identity: \(self.identity)")
        
        locationReporter.startMonitoring()
        
        broadcaster.start()
        discoverer.start()
        
        self.isActive = true
        
        delegate?.communicator(self, didStart: self.identity)
    }
    
    func stop() async throws {
        let identity = broadcaster.identity
        
        broadcaster.stop()
        discoverer.stop()
        
        self.isActive = false

        try await client.stopWaveDiscovery()
        
        delegate?.communicator(self, didStop: identity)
    }
    
    
}

extension WaveCommunicator: WaveDiscovererDelegate {
    func discoverer(_ discoverer: WaveDiscoverer, didDiscover sessionId: String, from location: CLLocation?) {
        let args = ReportWaveDiscoveryArgs(
            session_id: self.identity,
            discovered_session_id: sessionId,
            
            latitude: location?.coordinate.latitude,
            longitude: location?.coordinate.longitude,
            altitude: location?.altitude,
            
            accuracy: location?.horizontalAccuracy
        )
        Task {
            do {
                try await self.client.reportWaveDiscovery(args)
            } catch {
                print(error)
            }
        }
    }
}
