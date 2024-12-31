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
        VStack(spacing: 0) {
            MainTitlebar {
                NotificationButton(badged: false) {
                    print("TODO: Implement notification screen")
                }
                
                FlitzWaveButton(isOn: appState.waveActive) {
                    self.toggleWave()
                }
            }
            Spacer()
        }
    }
    
    func toggleWave() {
        let waveActive = appState.waveActive
        Task {
            if waveActive {
                try? await appState.waveCommunicator.stop()
            } else {
                try? await appState.waveCommunicator.start()
            }
        }
    }
}

#Preview {
    var appState = RootAppState()
    WaveScreen()
        .environmentObject(appState)
}
