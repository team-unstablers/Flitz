//
//  BLECommunicator.swift
//  FlitzCardExchangeTest
//
//  Created by Gyuhwan Park on 12/3/24.
//

import CoreBluetooth
import CoreLocation


class FlitzWaveCommunicator: ObservableObject {
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
    
    @Published
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
        
        DispatchQueue.main.async {
            self.isActive = true
            RootAppState.shared.waveActive = true
        }
    }
    
    func stop() async throws {
        broadcaster.stop()
        discoverer.stop()
        
        DispatchQueue.main.async {
            self.isActive = false
            RootAppState.shared.waveActive = false
        }

        try await client.stopWaveDiscovery()
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
