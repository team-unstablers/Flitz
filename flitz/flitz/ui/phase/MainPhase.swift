//
//  MainPhase.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/4/24.
//

import SwiftUI

struct MainPhase: View {
    @StateObject
    var appState: RootAppState = RootAppState()
    
    var body: some View {
        RootNavigation()
            .environmentObject(appState)
    }
}
