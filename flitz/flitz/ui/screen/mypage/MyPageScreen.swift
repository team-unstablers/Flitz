//
//  MyPageScreen.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/9/25.
//

import SwiftUI

struct MyPageHeaderButton: View {
    var iconName: String
    var title: String
    
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Spacer()
                VStack(alignment: .center, spacing: 8) {
                    Image(iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 42, height: 42)
                    Text(title)
                        .font(.fzHeading3)
                        .bold()
                }
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MyPageSectionDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.Grayscale.gray1)
            .frame(maxWidth: .infinity, maxHeight: 12)
    }
}

struct MyPageSectionHeader: View {
    var title: String
    
    var body: some View {
        VStack {
            Text(title)
                .foregroundStyle(Color.Grayscale.gray6)
                .font(.fzMain)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(minHeight: 44)
    }
}

struct MyPageSectionItem: View {
    var title: String
    var action: () -> Void
    
    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            VStack {
                Text(title)
                    .foregroundStyle(Color.Brand.black0)
                    .font(.fzHeading3)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(minHeight: 48)
            .contentShape(Rectangle())
        }
            .buttonStyle(PlainButtonStyle())
    }
}
    
    

struct MyPageScreen: View {
    @EnvironmentObject
    var appState: RootAppState
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        // FIXME: 프로필 정도는 캐싱해 두어야 하지 않을까요?
                        if let profile = appState.profile {
                            ProfileButton(profile: profile) {
                                print("TODO: navigate to profile edit screen")
                            }
                        } else {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .padding()
                        }
                        
                        HStack {
                            MyPageHeaderButton(iconName: "NoticeIcon", title: "공지사항") {
                                withAnimation {
                                    appState.assertionFailureReason = .mitmDetected
                                }
                            }
                            
                            // vertical line
                            Rectangle()
                                .fill(Color.Grayscale.gray1)
                                .frame(maxWidth: 1, maxHeight: .infinity)
                                .padding(.vertical, 8)
                            
                            MyPageHeaderButton(iconName: "SettingsIcon", title: "앱 설정") {
                                appState.navState.append(.settings)
                            }
                        }
                        .padding(.vertical, 20)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.Grayscale.gray3, lineWidth: 1)
                        )
                        .padding(.bottom, 20)
                    }
                    .padding(.horizontal, 16)
                    
                    MyPageSectionDivider()
                    
                    VStack(spacing: 0) {
                        MyPageSectionHeader(title: "개인 정보 보호")
                        MyPageSectionItem("사용자 보호 기능") {
                            print("TODO: navigate to change password screen")
                        }
                        MyPageSectionItem("차단된 사용자") {
                            
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    Rectangle()
                        .fill(Color.Grayscale.gray2)
                        .frame(maxWidth: .infinity, maxHeight: 1)
                        .padding(.vertical, 12)
                    
                    VStack(spacing: 0) {
                        MyPageSectionHeader(title: "고객 지원 및 도움말")
                        MyPageSectionItem("Flitz 도움말 보기") {
                            print("TODO: navigate to change password screen")
                        }
                        MyPageSectionItem("고객 지원에 문의하기") {
                            
                        }
                        MyPageSectionItem("개인정보 보호정책") {
                            
                        }
                        MyPageSectionItem("서비스 약관") {
                            
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    AboutAppFooter()
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.top, 12)
                        .padding(.horizontal, 16)
                    
                    VStack(alignment: .center) {
                        Text("Flitz version vX.Y.Z\nCopyright © 2025 team unstablers Inc.\nAll rights reserved.")
                            .foregroundStyle(Color.Grayscale.gray6)
                            .font(.caption2)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                        .padding(.vertical, 40)
                    
                }
            }
            .navigationTitle("마이페이지")
        }
    }
}

#Preview {
    MyPageScreen()
        .environmentObject(RootAppState())
}
