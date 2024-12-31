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
            
            DummyCardView()
                .shadow(radius: 8)
                .blur(radius: 8)
                .overlay {
                    VStack() {
                        Text("아직 교환된 카드가 없습니다.")
                            .font(.heading2)
                            .bold()
                            .foregroundStyle(Color.Grayscale.gray8)
                        
                        Text("Wave가 꺼져 있습니다.\nWave를 켜고 주변 사람들과 카드를 교환해 보세요!")
                            .multilineTextAlignment(.center)
                            .font(.main)
                            .foregroundStyle(Color.Grayscale.gray7)
                        
                        FZButton {
                            
                        } label: {
                            Text("Wave 시작하기")
                        }
                    }
                        .padding()
                }
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
