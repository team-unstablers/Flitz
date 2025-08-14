//
//  Untitled.swift
//  Flitz
//
//  Created by Gyuhwan Park on 1/4/25.
//

import SwiftUI

struct ProtectionSettingsScreen: View {
    @EnvironmentObject
    var appState: RootAppState
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                WaveSafetyZoneSettingsSection()
                    .padding(.horizontal, 16)
                
                FZPageSectionDivider()
                
                VStack(spacing: 0) {
                    FZPageSectionTitle(title: "연락처 미리 차단")
                    FZPageSectionItem("연락처에 등록된 사람들을 미리 차단하기") {
                        Toggle("", isOn: .constant(false))
                    }
                    
                    FZPageSectionActionItem("차단된 연락처 목록") {
                        
                    }
                    
                    FZPageSectionActionItem("이 기능에 대한 도움말 보기") {
                        
                    }
                    
                    FZPageSectionNote {
                        Text("이 기능을 사용하면, 연락처에 등록된 사람이 추후 Flitz 서비스에 가입하거나, Flitz 앱을 켠 상태로 마주치게 되더라도 서로를 확인할 수 없게 됩니다.".byCharWrapping)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .navigationTitle("사용자 보호 기능 설정")
    }
}

#Preview {
    ProtectionSettingsScreen()
        .environmentObject(RootAppState())
}
