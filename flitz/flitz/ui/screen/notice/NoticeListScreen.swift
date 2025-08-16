//
//  NoticeListScreen.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/17/25.
//

import SwiftUI

struct NoticeListItem: View {
    let title: String
    let createdAt: Date
    
    let action: (() -> Void)
    
    var body: some View {
        Button {
            action()
        } label: {
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title.byCharWrapping)
                            .font(.fzHeading3)
                            .foregroundStyle(Color.Brand.black0)
                            .lineLimit(1)
                        
                        Text(createdAt.localeDateString)
                            .font(.fzMain)
                            .foregroundStyle(Color.Grayscale.gray6)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Image("NavRightIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                }
                .padding(16)
                
                Divider()
                    .background(Color.Grayscale.gray2)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct NoticeListScreen: View {
    @EnvironmentObject
    var appState: RootAppState
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    NoticeListItem(title: "개인정보 처리방침 개정 안내", createdAt: Date()) {
                        navigate(to: "test")
                    }
                    NoticeListItem(title: "개인정보 처리방침 개정 안내", createdAt: Date()) {
                        navigate(to: "test")
                    }
                    NoticeListItem(title: "개인정보 처리방침 개정 안내", createdAt: Date()) {
                        navigate(to: "test")
                    }
                    NoticeListItem(title: "개인정보 처리방침 개정 안내", createdAt: Date()) {
                        navigate(to: "test")
                    }
                    NoticeListItem(title: "개인정보 처리방침 개정 안내", createdAt: Date()) {
                        navigate(to: "test")
                    }
                    NoticeListItem(title: "개인정보 처리방침 개정 안내", createdAt: Date()) {
                        navigate(to: "test")
                    }
                    NoticeListItem(title: "개인정보 처리방침 개정 안내", createdAt: Date()) {
                        navigate(to: "test")
                    }
                    NoticeListItem(title: "개인정보 처리방침 개정 안내", createdAt: Date()) {
                        navigate(to: "test")
                    }
                    NoticeListItem(title: "개인정보 처리방침 개정 안내", createdAt: Date()) {
                        navigate(to: "test")
                    }
                    NoticeListItem(title: "개인정보 처리방침 개정 안내", createdAt: Date()) {
                        navigate(to: "test")
                    }
                    NoticeListItem(title: "개인정보 처리방침 개정 안내", createdAt: Date()) {
                        navigate(to: "test")
                    }
                }
            }
        }
            .navigationTitle("공지사항")
    }
    
    func navigate(to noticeId: String) {
        appState.navState.append(.noticeDetail(noticeId: noticeId))
    }
}

#Preview {
    NoticeListScreen()
        .environmentObject(RootAppState())
}
