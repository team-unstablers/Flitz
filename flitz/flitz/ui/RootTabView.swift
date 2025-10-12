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
    
    @State
    var conversationUnreadCount: Int = 0
    
    @State
    var _updateUnreadCountTask: Task<Void, Never>? = nil
    
    init() {
    }
    
    func resetTabBarStyle() {
        if #available(iOS 26.0, *) {
            return
        } else {
            UITabBar.appearance().isTranslucent = true
            UITabBar.appearance().backgroundColor = .white
        }
    }
    
    var body: some View {
        TabView(selection: $appState.currentTab) {
            WaveScreen()
                .tag(RootTab.wave)
                .tabItem {
                    Image(systemName: "arrow.2.circlepath")
                    Text(NSLocalizedString("ui.tab.wave", comment: "웨이브"))
                }
            ConversationListScreen()
                .tag(RootTab.messages)
                .tabItem {
                    Image(systemName: "message")
                    Text(NSLocalizedString("ui.tab.message", comment: "메시지"))
                }
                .badge(conversationUnreadCount > 0 ? (conversationUnreadCount > 99 ? "99+" : "\(conversationUnreadCount)") : nil)
            StoreRootScreen()
                .tag(RootTab.store)
                .tabItem {
                    Image(systemName: "house")
                    Text(NSLocalizedString("ui.tab.store", comment: "스토어"))
                }
            MyPageScreen()
                .tag(RootTab.profile)
                .tabItem {
                    Image(systemName: "person")
                    Text(NSLocalizedString("ui.tab.profile", comment: "프로필"))
                }
        }
        .onAppear {
            resetTabBarStyle()
            updateConversationUnreadCount()
        }
        .onReceive(appState.conversationBadgeUpdated) { _ in
            updateConversationUnreadCount()
        }
        .onScenePhase(.active, immediate: true) {
            updateConversationUnreadCount()
        }
    }
    
    func updateConversationUnreadCount() {
        guard appState.navState.isEmpty else {
            return
        }

        _updateUnreadCountTask?.cancel()
        _updateUnreadCountTask = Task {
            await updateConversationUnreadCountInternal()
            _updateUnreadCountTask = nil
        }
    }
    
    @MainActor
    func updateConversationUnreadCountInternal() async {
        try? await Task.sleep(for: .milliseconds(300)) // ㅋ_ㅋ
        
        do {
            async let response = appState.client.conversationsTotalUnreadCount()
            let count = try await response.total_unread_count
            
            self.conversationUnreadCount = count
        } catch {
            print("Failed to fetch unread count: \(error)")
        }
    }
}
