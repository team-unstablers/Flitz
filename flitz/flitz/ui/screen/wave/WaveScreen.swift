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
                    Text("아직 교환받은 카드가 없습니다.")
                    Button("FlitzWave 시작하기") {
                        Task {
                            try? await appState.waveCommunicator.start()
                        }
                    }
                }
            }
            .navigationTitle("최근 교환받은 카드")
        }
    }
}

#Preview {
    var appState = RootAppState()
    WaveScreen()
        .environmentObject(appState)
}
