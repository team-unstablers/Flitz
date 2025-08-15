//
//  MainPhase.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/4/24.
//

import SwiftUI

struct MainPhase: View {
    @StateObject
    var appState: RootAppState = RootAppState.shared
    
    var body: some View {
        RootNavigation()
            .environmentObject(appState)
            .environment(\.userId, appState.profile?.id ?? UserIdKey.defaultValue)
            .onAppear() {
                UNUserNotificationCenter.setup()
                appState.loadProfile()
            }
        /*
            .onScenePhase(.active, immediate: false) {
                WaveLocationReporter.shared.requestLocation()
            }
         */
    }
}
