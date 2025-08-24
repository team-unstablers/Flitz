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


class WaveCommunicator: NSObject {
    static var serviceEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: "FlitzWaveEnabled")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "FlitzWaveEnabled")
        }
    }
    
    var client: FZAPIClient
    
    let locationReporter = WaveLocationReporter.shared
    
    private let logger = createFZOSLogger("WaveCommunicator")
    
    var discoverer: WaveDiscoverer!
    var broadcaster: WaveBroadcaster!
    
    var identity: String? {
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

        super.init()
        
        discoverer.delegate = self
        broadcaster = WaveBroadcaster(delegate: self)
        
        if client.context.id != nil {
            locationReporter.startMonitoring()
        }
    }
    
    func recoverState() async throws {
        guard Self.serviceEnabled else {
            return
        }
        
        try await self.start()
    }
    
    func start() async throws {
        guard self.identity == nil, !self.isActive else {
            return
        }
        
        let session = try await client.startWaveDiscovery()
        self.identity = session.session_id
        
        logger.info("starting wave with identity: \(session.session_id)")
        
        locationReporter.startMonitoring()
        
        broadcaster.start()
        discoverer.start()
        
        self.isActive = true
        
        await MainActor.run {
            delegate?.communicator(self, didStart: session.session_id)
        }
    }
    
    func stop() async throws {
        guard let identity = self.identity else {
            return
        }
        
        try await client.stopWaveDiscovery()

        broadcaster.stop()
        discoverer.stop()
        
        self.isActive = false
        self.identity = nil
        
        await MainActor.run {
            delegate?.communicator(self, didStop: identity)
        }
    }
    
    
}

extension WaveCommunicator: WaveDiscovererDelegate {
    func discoverer(_ discoverer: WaveDiscoverer, didDiscover sessionId: String, from location: CLLocation?, peripheral uuid: UUID) {
        guard let identity = self.identity else {
            logger.warning("WaveCommunicator: No active session to report discovery")
            return
        }
        
        let args = ReportWaveDiscoveryArgs(
            session_id: identity,
            discovered_session_id: sessionId,
            
            latitude: location?.coordinate.latitude,
            longitude: location?.coordinate.longitude,
            altitude: location?.altitude,
            
            accuracy: location?.horizontalAccuracy
        )
        Task {
            do {
                try await self.client.reportWaveDiscovery(args)
                discoverer.markAsDiscovered(uuid)
            } catch {
                logger.error("\(error)")
            }
        }
    }
}

extension WaveCommunicator: WaveBroadcasterDelegate {
    func broadcasterDidRestoreState(_ broadcaster: WaveBroadcaster) {
        Task {
            try? await self.recoverState()
        }
    }
}
