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
        TabView(selection: $currentTab) {
            Group {
                DashboardScreen()
                    .tag(RootTab.dashboard)
                    .tabItem {
                        Image(systemName: "house")
                        Text("Dashboard")
                    }
                ReceivedCardListScreen()
                    .tag(RootTab.exchangedCards)
                    .tabItem {
                        Image(systemName: "arrow.2.circlepath")
                        Text("Exchanged Cards")
                    }
                DashboardScreen()
                    .tag(RootTab.messages)
                    .tabItem {
                        Image(systemName: "message")
                        Text("Messages")
                    }
                CardListScreen()
                    .tag(RootTab.profile)
                    .tabItem {
                        Image(systemName: "person")
                        Text("Profile")
                    }
            }
        }
    }
    
}
