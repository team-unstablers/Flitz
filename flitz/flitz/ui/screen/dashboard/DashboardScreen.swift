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
            .navigationTitle("Dashboard")
        }
        .onAppear {
            if appState.profile == nil {
                appState.loadProfile()
            }
        }
    }
    
    
}
    
