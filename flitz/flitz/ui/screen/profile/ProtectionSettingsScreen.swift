//
//  ProtectionSettingsScreen.swift
//  Flitz
//
//  Created by Gyuhwan Park on 1/4/25.
//

import SwiftUI

struct ProtectionSettingsScreen: View {
    var body: some View {
        Form {
            Section {
                Toggle(isOn: .constant(false)) {
                    Text("자동으로 Wave 끄기 (베타)")
                }
                Toggle(isOn: .constant(false)) {
                    Text("장소에서 벗어나면 다시 Wave 켜기")
                }
                
                Button {
                    
                } label: {
                    Text("위치 지정하기")
                }
                
            } header: {
                Text("자동으로 Wave 끄기 (베타)")
            } footer: {
                Text("특정 장소에 도착하면, 자동으로 Wave를 끄고 오프라인 상태로 전환합니다. 오프라인 상태에서는 상대방이 당신을 발견하거나 Wave할 수 없게 됩니다.")
            }
            Section {
                Toggle(isOn: .constant(false)) {
                    Text("지정된 연락처 미리 차단하기")
                }
                Button {
                    
                } label: {
                    Text("차단할 연락처 목록")
                }
                
                Button {
                    
                } label: {
                    Text("이 기능에 대한 도움말 보기")
                }
                
            } header: {
                Text("연락처 미리 차단")
            } footer: {
                Text("이 기능을 사용하면, 연락처에 등록된 사람이 추후 Flitz 서비스에 가입하거나, Flitz 앱을 켠 상태로 마주치게 되더라도 서로를 확인할 수 없게 됩니다.")
            }
            
            Section {
                Toggle(isOn: .constant(false)) {
                    Text("지정된 연락처에 대해 표시 제한하기")
                }
                Button {
                    
                } label: {
                    Text("표시 제한할 연락처 목록")
                }
                Button {
                    
                } label: {
                    Text("이 기능에 대한 도움말 보기")
                }
            } header: {
                Text("연락처 표시 제한하기")
            } footer: {
                Text("이 기능을 사용하면, 연락처에 등록된 사람과 마주치게 되어 서로 카드가 교환되었을 때, 아래와 같은 제한이 적용됩니다.\n\n- 서로의 프로필 카드가 단색으로 표시됩니다.\n- 카드 중앙에 다음과 같은 메시지가 표시됩니다: \"당신이 알 수도 있는 사용자이기 때문에 이 카드의 표시를 제한하였습니다. 버튼을 누르면 카드를 조회할 수 있지만, 당신이 이 카드를 조회했다는 사실이 상대방에게 전송됩니다.\"\n- 상대방이 카드를 조회하면 알림을 받게 됩니다.")
            }
        }
        .navigationTitle("사용자 보호 기능 설정")
    }
}

#Preview {
    ProtectionSettingsScreen()
}




