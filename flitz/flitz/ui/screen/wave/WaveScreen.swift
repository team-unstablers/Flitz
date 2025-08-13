//
//  WaveScreen.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/7/24.
//

import SwiftUI

struct WaveScreen: View {
    static let tabs: [FZTab] = [
        FZTab(id: "exchanged", title: "최근"),
        FZTab(id: "liked-cards", title: "보관함"),
        FZTab(id: "my-cards", title: "내 카드"),
    ]
    
    @EnvironmentObject
    var appState: RootAppState
    
    @State
    var selectedTabId: String = Self.tabs.first!.id
    
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
            
            FZInlineTab(tabs: Self.tabs, selectedTabId: $selectedTabId)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            
            VStack(spacing: 0) {
                if selectedTabId == "exchanged" {
                    ExchangedCards()
                } else if selectedTabId == "liked-cards" {
                    EmptyView()
                } else if selectedTabId == "my-cards" {
                    CardManagerView()
                }
            }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .animation(.easeInOut(duration: 0.2), value: selectedTabId)
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
