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
                VStack(spacing: 0) {
                    FZPageSectionTitle(title: "알림 설정")
                    FZPageSectionItem("채팅 알림 받기") {
                        Toggle("", isOn: .constant(false))
                    }
                    FZPageSectionItem("매칭 알림 받기") {
                        Toggle("", isOn: .constant(true))
                    }
                    FZPageSectionItem("중요한 공지 알림 받기") {
                        Toggle("", isOn: .constant(true))
                    }
                    FZPageSectionItem("쓸데없는 알림 받기") {
                        Toggle("", isOn: .constant(true))
                    }
                }
                .padding(.horizontal, 16)
                
                FZPageSectionDivider()
                
                VStack(spacing: 0) {
                    FZPageSectionTitle(title: "계정 관리")
                    FZPageSectionActionItem("비밀번호 변경") {
                        
                    }
                    
                    FZPageSectionActionItem("로그아웃") {
                        
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
