//
//  ContentView.swift
//  Flitz WaveSpot
//
//  Created by Gyuhwan Park on 9/13/25.
//

import SwiftUI

enum FatalReason {
    case insufficientPermissions
    case authorizationFailed
}

enum AppPhase {
    case splash
    case main
    case fatal(reason: FatalReason)
}

@MainActor
class AppRootViewModel: ObservableObject, @preconcurrency WaveSpotClientDelegate {
    @Published
    var phase: AppPhase = .main
    
    // ViewModel logic here
    let waveSpotClient = WaveSpotClient.shared
    
    func initialize() {
        waveSpotClient.delegate = self
        waveSpotClient.bootstrap()
    }
    
    func waveSpotClientDidRequestLocationPermission(_ client: WaveSpotClient) {
    }
    
    func waveSpotClientDidAuthorize(_ client: WaveSpotClient, token: String) {
    }
    
    func waveSpotClient(_ client: WaveSpotClient, didFailWithError error: any Error) {
        print("WaveSpotClient did fail with error: \(error)")
        Task { @MainActor in
            self.phase = .fatal(reason: .authorizationFailed)
        }
    }
}


struct AppRoot: View {
    
    @StateObject
    var viewModel = AppRootViewModel()
    
    var body: some View {
        switch (viewModel.phase) {
        case .splash:
            VStack {
                Image("WaveSpotLogo")
                
                ProgressView()
                    .padding(.vertical, 32)
                
                Text("잠시만 기다려 주세요...")
            }
            .padding()
            .onAppear {
                viewModel.initialize()
            }
            
        case .main:
            MainPhase()
            
        case .fatal(let reason):
            VStack {
                Image("WaveSpotLogo")
                    .padding(.bottom, 32)
                
                Text("현재 위치를 알 수 없습니다.\n매장 안에 있는지, 위치 권한이 허용되어 있는지 확인해 주세요.")
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
    }
}

#Preview {
    AppRoot()
}
