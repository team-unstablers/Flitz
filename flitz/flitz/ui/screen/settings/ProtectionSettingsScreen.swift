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
                VStack(spacing: 0) {
                    FZPageSectionTitle(title: "자동으로 Wave 끄기 (베타)")
                    FZPageSectionItem("자동으로 Wave 끄기 (베타)") {
                        Toggle("", isOn: .constant(false))
                    }
                    FZPageSectionItem("장소에서 벗어나면 다시 Wave 켜기") {
                        Toggle("", isOn: .constant(true))
                    }
                    FZPageSectionActionItem("위치 지정하기") {
                        
                    }
                    
                    FZPageSectionNote() {
                        Text("특정 장소에 도착하면, 자동으로 Wave를 끄고 오프라인 상태로 전환합니다. 오프라인 상태에서는 상대방이 당신을 발견하거나 Wave할 수 없게 됩니다.".byCharWrapping)
                    }
                }
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
