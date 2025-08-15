//
//  Wave.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/4/24.
//

import Foundation

struct ReportWaveDiscoveryArgs: Codable {
    let session_id: String
    let discovered_session_id: String
    
    let latitude: Double?
    let longitude: Double?
    let altitude: Double?
    let accuracy: Double?
}

struct WaveUpdateLocationArgs: Codable {
    let latitude: Double?
    let longitude: Double?
    let altitude: Double?
    let accuracy: Double?
}
