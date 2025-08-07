//
//  FZAPIClient+Wave.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/1/25.
//

extension FZAPIClient {
    func startWaveDiscovery() async throws -> WaveDiscoverySessionInfo {
        return try await self.request(to: .waveDiscoveryStart, expects: WaveDiscoverySessionInfo.self, method: .post)
    }
    
    func stopWaveDiscovery() async throws {
        _ = try await self.request(to: .waveDiscoveryEnd, expects: Ditch.self, method: .post)
    }
    
    func reportWaveDiscovery(_ args: ReportWaveDiscoveryArgs) async throws {
        _ = try await self.request(to: .waveReportDiscovery,
                                   expects: Ditch.self,
                                   method: .post,
                                   parameters: args)
    }
    
}
