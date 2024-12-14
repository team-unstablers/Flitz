//
//  WaveScreen.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/7/24.
//

import SwiftUI

struct WaveScreen: View {
    @EnvironmentObject
    var appState: RootAppState
    
    var body: some View {
        NavigationView {
            VStack {
                if appState.waveActive {
                    Button("FlitzWave 멈추기") {
                        Task {
                            try? await appState.waveCommunicator.stop()
                        }
                    }
                } else {
                    Button("FlitzWave 시작하기") {
                        Task {
                            try? await appState.waveCommunicator.start()
                        }
                    }
                }
            }
            .navigationTitle("Wave")
        }
    }
}

#Preview {
    var appState = RootAppState()
    WaveScreen()
        .environmentObject(appState)
}
