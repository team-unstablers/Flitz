//
//  Untitled.swift
//  Flitz
//
//  Created by Gyuhwan Park on 1/4/25.
//

import SwiftUI

struct SettingsScreen: View {
    @EnvironmentObject
    var appState: RootAppState
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                NotificationSettingsSection()
                    .padding(.horizontal, 16)
                
                FZPageSectionDivider()
                
                VStack(spacing: 0) {
                    FZPageSectionTitle(title: "ui.settings.account.title")
                    FZPageSectionActionItem("ui.settings.account.change_password") {
                        appState.navState.append(.passwd)
                    }
                    
                    FZPageSectionActionItem("ui.settings.account.logout") {
                        RootAppState.shared.logout()
                        appState.navState.append(.logoutCompleted(reason: .byUser))
                    }
                    
                    FZPageSectionActionItem("ui.settings.account.deactivate_account") {
                        appState.navState.append(.deactivateAccount)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .navigationTitle("ui.settings.page_title")
    }
}

#Preview {
    SettingsScreen()
        .environmentObject(RootAppState())
}
