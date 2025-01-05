//
//  Untitled.swift
//  Flitz
//
//  Created by Gyuhwan Park on 1/4/25.
//

import SwiftUI

fileprivate struct ProfileButton: View {
    var profile: FZUser
    
    var body: some View {
        Button {} label: {
            HStack {
                ProfileImage(
                    url: profile.profile_image_url,
                    size: 72
                )
                
                VStack(alignment: .leading) {
                    Text(profile.display_name)
                        .font(.heading2)
                        .bold()
                    
                    Text("프로필 편집하기")
                        .font(.main)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

struct SettingsScreen: View {
    @EnvironmentObject
    var appState: RootAppState
    
    var body: some View {
        Form {
            Section {
                if let profile = appState.profile {
                    ProfileButton(profile: profile)
                } else {
                    ProgressView()
                        .onAppear {
                            appState.loadProfile()
                        }
                }
            }
            
            Section(header: Text("개인 정보 보호")) {
                Button(action: {
                    appState.navState.append(.protectionSettings)
                }) {
                    Text("사용자 보호 기능")
                }
                
                Button(action: {
                    print("Sign out")
                }) {
                    Text("차단된 사용자")
                }
            }
            
            Section(header: Text("계정 관리")) {
                Button(role: .destructive, action: {
                    print("Sign out")
                }) {
                    Text("로그아웃하기")
                }
                Button(role: .destructive, action: {
                    print("Sign out")
                }) {
                    Text("Flitz 계정 삭제하기")
                }
            }
            
            Section(header: Text("고객 지원 및 도움말")) {
                Button(action: {
                    print("Terms of service")
                }) {
                    Text("Flitz 도움말 보기")
                }
                
                Button(action: {
                    print("Contact us")
                }) {
                    Text("고객 지원에 문의하기")
                }
                
                Button(action: {
                    print("Privacy policy")
                }) {
                    Text("개인정보 보호정책")
                }
                
                Button(action: {
                    print("Terms of service")
                }) {
                    Text("서비스 약관")
                }
            }
            
            AboutAppFooter()
                .listRowInsets(EdgeInsets())
            
            Section {
                
            } footer: {
                Text("Flitz v1.0.0\n" +
                     "© 2025 team unstablers Inc. All rights reserved.")
            }
            
            
        }
    }
}

#Preview {
    SettingsScreen()
        .environmentObject(RootAppState())
}
