//
//  RootNavigation.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/4/24.
//

import SwiftUI

enum RootNavigationItem: Hashable {
    case cardEditor(cardId: String)
    case conversation(conversationId: String)
    
    case settings
    case protectionSettings
}

struct RootNavigation: View {
    @EnvironmentObject
    var appState: RootAppState
    
    var body: some View {
        NavigationStack(path: $appState.navState) {
            RootTabView()
                .navigationDestination(for: RootNavigationItem.self) { item in
                    switch (item) {
                    case .cardEditor(let cardId):
                        CardEditor(cardId: cardId, client: $appState.client)
                    
                    case .conversation(let conversationId):
                        ConversationScreen(conversationId: conversationId)
                        
                    case .settings:
                        SettingsScreen()
                    case .protectionSettings:
                        ProtectionSettingsScreen()
                        
                    default:
                        EmptyView()
                    }
                }
        }
    }
}
