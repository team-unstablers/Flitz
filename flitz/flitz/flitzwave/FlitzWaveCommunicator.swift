//
//  BLECommunicator.swift
//  FlitzCardExchangeTest
//
//  Created by Gyuhwan Park on 12/3/24.
//

import CoreBluetooth
import CoreLocation

protocol FlitzWaveCommunicatorDelegate: AnyObject {
    func communicator(_ communicator: FlitzWaveCommunicator, didStart sessionId: String)
    func communicator(_ communicator: FlitzWaveCommunicator, didStop sessionId: String)
}


@MainActor
class FlitzWaveCommunicator {
    var client: FZAPIClient
    
    let discoverer = FlitzWaveDiscoverer()
    let broadcaster = FlitzWaveBroadcaster()
    
    var identity: String {
        get {
            return broadcaster.identity
        }
        set {
            broadcaster.identity = newValue
        }
    }
    
    weak var delegate: FlitzWaveCommunicatorDelegate? = nil
    
    private(set) var isActive: Bool = false
    
    init(with client: FZAPIClient) {
        self.client = client
        
        discoverer.delegate = self
    }
    
    func start() async throws {
        let session = try await client.startWaveDiscovery()
        self.identity = session.session_id
        
        print("starting wave with identity: \(self.identity)")
        
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

extension FlitzWaveCommunicator: FlitzWaveDiscovererDelegate {
    func discoverer(_ discoverer: FlitzWaveDiscoverer, didDiscover sessionId: String, from location: CLLocation?) {
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
