//
//  MyPageScreen.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/9/25.
//

import SwiftUI

struct MyPageHeaderButton: View {
    var iconName: String
    var title: LocalizedStringKey
    
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


struct MyPageScreen: View {
    @Environment(\.openURL)
    var openURL
    
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
                                appState.navState.append(.editProfile)
                            }
                        } else {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .padding()
                        }
                        
                        HStack {
                            MyPageHeaderButton(iconName: "NoticeIcon", title: "ui.mypage.notice") {
                                appState.navState.append(.noticeList)
                            }
                            
                            // vertical line
                            Rectangle()
                                .fill(Color.Grayscale.gray1)
                                .frame(maxWidth: 1, maxHeight: .infinity)
                                .padding(.vertical, 8)
                            
                            MyPageHeaderButton(iconName: "SettingsIcon", title: "ui.mypage.settings") {
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
                    
                    FZPageSectionLargeDivider()
                    
                    VStack(spacing: 0) {
                        FZPageSectionTitle(title: "ui.mypage.privacy.title")
                        FZPageSectionActionItem("ui.mypage.privacy.safety") {
                            appState.navState.append(.protectionSettings)
                        }
                        FZPageSectionActionItem("ui.mypage.privacy.blocked_users") {
                            appState.navState.append(.blockedUsers)
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    FZPageSectionDivider()
                    
                    VStack(spacing: 0) {
                        FZPageSectionTitle(title: "ui.mypage.support.title")
                        FZPageSectionActionItem("ui.mypage.support.about_prelude") {
                            openURL(URL(string: "http://docs.flitz.cards/help/prelude/")!)
                        }
                        FZPageSectionActionItem("ui.mypage.support.send_feedback") {
                            openURL(URL(string: "https://docs.google.com/forms/d/e/1FAIpQLScDLdnQWOqNZKFSH7YmU5YMAhXD_vkYdfxR_rMUZkt78a_hPw/viewform?usp=dialog")!)
                        }
                        FZPageSectionActionItem("ui.mypage.support.support_form") {
                            appState.navState.append(.ticketList)
                        }
                        FZPageSectionActionItem("ui.mypage.support.privacy_policy") {
                            openURL(URL(string: "https://docs.flitz.cards/legal/kr/privacy-policy.html")!)
                        }
                        FZPageSectionActionItem("ui.mypage.support.tos_location") {
                            openURL(URL(string: "https://docs.flitz.cards/legal/kr/tos-location.html")!)
                        }
                        FZPageSectionActionItem("ui.mypage.support.tos") {
                            openURL(URL(string: "https://docs.flitz.cards/legal/kr/tos.html")!)
                        }
                        FZPageSectionActionItem("ui.mypage.support.oss_licenses") {
                            openURL(URL(string: "https://docs.flitz.cards/legal/oss.html")!)
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    FZPageSectionDivider()
                    
                    VStack(spacing: 0) {
                        FZPageSectionTitle(title: "ui.mypage.safety_resources.title")
                        ForEach(SafetyResources.Korean.allCases, id: \.self) { resource in
                            FZPageSectionActionItemWithSubtitle(resource.name, subtitle: resource.description) {
                                if let importantNote = resource.importantNote {
                                    let notificationCenter = UNUserNotificationCenter.current()
                                    notificationCenter.removeDeliveredNotifications(withIdentifiers: [resource.id])
                                    
                                    let notificationContent = UNMutableNotificationContent()
                                    
                                    notificationContent.title = importantNote.title
                                    if let subtitle = importantNote.subtitle {
                                        notificationContent.subtitle = subtitle
                                    }
                                    notificationContent.body = importantNote.message
                                    
                                    notificationContent.sound = .default
                                    notificationContent.interruptionLevel = .critical
                                    notificationContent.categoryIdentifier = "SafetyResourceNotification"
                                    
                                    let notificationRequest = UNNotificationRequest(identifier: resource.id,
                                                                                    content: notificationContent,
                                                                                    trigger: nil)
                                    
                                    
                                    notificationCenter.add(notificationRequest)
                                }
                                
                                openURL(resource.url)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    AboutAppFooter()
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.top, 12)
                        .padding(.horizontal, 16)
                    
                    VStack(alignment: .center) {
                        Text("Flitz version \(Flitz.version) \"\(Flitz.codename)\"\nCopyright © 2025 team unstablers Inc.\nAll rights reserved.")
                            .foregroundStyle(Color.Grayscale.gray6)
                            .font(.caption2)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.bottom, 16)
                        
                        Text("**주식회사 팀언스테이블러즈**\n[https://unstabler.pl](https://unstabler.pl)")
                            .foregroundStyle(Color.Grayscale.gray6)
                            .font(.caption2)
                            .multilineTextAlignment(.center)
                            .tintColor(.blue)
                            .lineSpacing(4)

                        
                        /*
                        Text("상호명 **주식회사 팀언스테이블러즈**  사업자등록번호 **473-81-02068**\n통신판매업 신고번호 **2025-경기안산-2861**\n주소 **(15495) 경기도 안산시 광덕1로 362 5층 518호**")
                            .foregroundStyle(Color.Grayscale.gray6)
                            .font(.caption2)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                         */
                    }
                    .padding(.vertical, 40)
                    
                }
            }
            .navigationTitle(NSLocalizedString("ui.mypage.page_title", comment: "마이페이지"))
        }
    }
}

#Preview {
    MyPageScreen()
        .environmentObject(RootAppState())
}
