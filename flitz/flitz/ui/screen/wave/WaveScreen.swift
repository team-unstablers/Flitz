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
        FZTab(id: "debug-screen", title: "디버그"),
    ]
    
    @EnvironmentObject
    var appState: RootAppState
    
    @State
    var selectedTabId: String = Self.tabs.first!.id
    
    @StateObject
    var waveCardManagerViewModel = WaveCardManagerViewModel()
    
    @StateObject
    var favoritedCardsViewModel = FavoritedCardsViewModel()
    
    @StateObject
    var cardManagerViewModel = CardManagerViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            MainTitlebar {
                /*
                NotificationButton(badged: false) {
                    print("TODO: Implement notification screen")
                }
                 */
                
                FlitzWaveButton(isOn: appState.waveActive) {
                    self.toggleWave()
                }
            }
            
            FZInlineTab(tabs: Self.tabs, selectedTabId: $selectedTabId)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            
            VStack(spacing: 0) {
                if selectedTabId == "exchanged" {
                    WaveCardManagerView(viewModel: waveCardManagerViewModel)
                } else if selectedTabId == "liked-cards" {
                    FavoritedCards(viewModel: favoritedCardsViewModel)
                } else if selectedTabId == "my-cards" {
                    CardManagerView(viewModel: cardManagerViewModel)
                } else if selectedTabId == "debug-screen" {
                    FZCardViewEx()
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
                WaveCommunicator.serviceEnabled = false
                try? await appState.waveCommunicator.stop()
            } else {
                WaveCommunicator.serviceEnabled = true
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
