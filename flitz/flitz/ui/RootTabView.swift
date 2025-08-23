//
//  RootTabView.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/4/24.
//

import SwiftUI

enum RootTab: Hashable {
    case wave
    case store
    case messages
    case profile
}

struct RootTabView: View {
    @EnvironmentObject
    var appState: RootAppState
    
    init() {
        UITabBar.appearance().isTranslucent = false
        UITabBar.appearance().backgroundColor = .white
    }
    
    var body: some View {
        ZStack {
            TabView(selection: $appState.currentTab) {
                WaveScreen()
                    .tag(RootTab.wave)
                    .tabItem {
                        Image(systemName: "arrow.2.circlepath")
                        Text("웨이브")
                    }
                ConversationListScreen()
                    .tag(RootTab.messages)
                    .tabItem {
                        Image(systemName: "message")
                        Text("메시지")
                    }
                Text("아직 구현되지 않았습니다")
                    .tag(RootTab.store)
                    .tabItem {
                        Image(systemName: "house")
                        Text("스토어")
                    }
                MyPageScreen()
                    .tag(RootTab.profile)
                    .tabItem {
                        Image(systemName: "person")
                        Text("프로필")
                    }
            }
        }
    }
}
