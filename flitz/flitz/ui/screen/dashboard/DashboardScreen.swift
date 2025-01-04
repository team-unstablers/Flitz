//
//  DashboardScreen.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/4/24.
//

import SwiftUI

struct DashboardScreen: View {
    @EnvironmentObject
    var appState: RootAppState
    
    @State
    var isResetAlertPresented = false
    
    var body: some View {
        NavigationView {
            VStack {
                if let profile = appState.profile {
                    Text("Welcome, \(profile.username)")
                    
                    if appState.waveCommunicator.isActive {
                        Button("stop wave") {
                            Task {
                                try? await appState.waveCommunicator.stop()
                            }
                        }
                    } else {
                        Button("start wave") {
                            Task {
                                try? await appState.waveCommunicator.start()
                            }
                        }
                    }
                    
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("대시보드")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("로그아웃") {
                    FZAPIContext.reset()
                    isResetAlertPresented = true
                }
                .alert("로그아웃 되었으므로 앱을 다시 기동하여 주십시오. (죄송합니다! 💦💦)", isPresented: $isResetAlertPresented) {
                    
                }
            }
            
        }
        .onAppear {
            if appState.profile == nil {
                appState.loadProfile()
            }
        }
    }
    
    
}
    
