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
                    FZPageSectionTitle(title: "계정 관리")
                    FZPageSectionActionItem("비밀번호 변경") {
                        appState.navState.append(.passwd)
                    }
                    
                    FZPageSectionActionItem("로그아웃") {
                        RootAppState.shared.logout()
                    }
                    
                    FZPageSectionActionItem("Flitz 계정 삭제하기") {
                        
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .navigationTitle("설정")
    }
}

#Preview {
    SettingsScreen()
        .environmentObject(RootAppState())
}
