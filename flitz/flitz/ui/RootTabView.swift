//
//  RootTabView.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/4/24.
//

import SwiftUI

enum RootTab: Hashable {
    case dashboard
    case exchangedCards
    case messages
    case profile
}

struct RootTabView: View {
    @State
    var currentTab: RootTab = .dashboard
    
    var body: some View {
        ZStack {
            TabView(selection: $currentTab) {
                Group {
                    DashboardScreen()
                        .tag(RootTab.dashboard)
                    WaveScreen()
                        .tag(RootTab.exchangedCards)
                    Text("아직 구현되지 않았습니다")
                        .tag(RootTab.messages)
                    CardListScreen()
                        .tag(RootTab.profile)
                }
            }
            .toolbar(.hidden, for: .tabBar)
            
            GeometryReader { geom in
                RootNavbar(activeTab: $currentTab)
                    .position(x: geom.size.width / 2, y: geom.size.height - 34)
            }
        }
    }
}
