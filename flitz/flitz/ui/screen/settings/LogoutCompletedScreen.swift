//
//  ConfirmDeactivateScreen.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/22/25.
//

import SwiftUI

enum LogoutReason: Hashable {
    case byUser
    case byAnotherSession
    
    var localizedTitle: String {
        switch self {
        case .byAnotherSession:
            return NSLocalizedString("logout.reason.title.by_another_session", comment: "다른 세션에 의해 로그아웃됨 / 타이틀 (다른 기기에서 접속하여 로그아웃 되었습니다)")
            
        case .byUser:
            fallthrough
        default:
            return NSLocalizedString("logout.reason.title.by_user", comment: "사용자에 의해 로그아웃됨 / 타이틀 (로그아웃 되었습니다)")
        }
    }
    
    var localizedDescription: String {
        switch self {
        case .byAnotherSession:
            return NSLocalizedString("logout.reason.description.by_another_session", comment: "다른 세션에 의해 로그아웃됨 / 설명 (다른 기기에서 접속하여 로그아웃 되었습니다)")
            
        case .byUser:
            fallthrough
        default:
            return NSLocalizedString("logout.reason.description.by_user", comment: "사용자에 의해 로그아웃됨 / 설명 (로그아웃이 완료되었습니다.)")
        }
    }
}

struct LogoutCompletedScreen: View {
    let reason: LogoutReason
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(reason.localizedTitle.byCharWrapping)
                            .font(.fzHeading1)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(reason.localizedDescription.byCharWrapping)
                            .font(.fzMain)
                            .foregroundStyle(Color.Grayscale.gray6)
                    }
                        .padding(.top, 40)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal)
            }
            VStack {
                FZButton(size: .large) {
                    Flitz.exitGracefully()
                } label: {
                    Text(LocalizedStringKey("ui.general.quit_app"))
                        .font(.fzHeading3)
                        .semibold()
                }
            }
            .padding(16)
        }
        .navigationTitle(NSLocalizedString("ui.settings.logout_completed.page_title", comment: "로그아웃 완료"))
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    LogoutCompletedScreen(reason: .byAnotherSession)
        .environmentObject(RootAppState())
}
