//
//  RootNavbar.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/5/24.
//

import SwiftUI

extension RootTab {
    var icon: String {
        switch self {
        case .dashboard:
            return "house"
        case .exchangedCards:
            return "arrow.2.circlepath"
        case .messages:
            return "message"
        case .profile:
            return "person"
        }
    }
    
    var label: String {
        switch self {
        case .dashboard:
            return "홈"
        case .exchangedCards:
            return "웨이브"
        case .messages:
            return "메시지"
        case .profile:
            return "내 프로필"
        }
    }
    
    var color: Color {
        switch self {
        case .dashboard:
            return Color.Brand.orange0
        case .exchangedCards:
            return Color.Brand.blue0
        case .messages:
            return Color.Brand.green0
        case .profile:
            return Color.Brand.yellow0
        }
    }
}

struct NavbarButton: View {
    var tab: RootTab
    var isActive: Bool = false
    
    var handler: () -> Void
    
    var body: some View {
        Button {
            handler()
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 20))
                    .frame(width: 20, height: 20)
                Text(tab.label)
                    .font(.small)
                    .bold(isActive)
            }
            .foregroundStyle(isActive ? tab.color : Color(hex: 0xBDBDBD))
        }
        .frame(width: 64)
    }
}

struct RootNavbar: View {
    @Binding
    var activeTab: RootTab
    
    var body: some View {
        HStack {
            Group {
                Spacer()
                NavbarButton(tab: .dashboard, isActive: activeTab == .dashboard) {
                    activeTab = .dashboard
                }
                Spacer()
                NavbarButton(tab: .exchangedCards, isActive: activeTab == .exchangedCards) {
                    activeTab = .exchangedCards
                }
                Spacer()
                NavbarButton(tab: .messages, isActive: activeTab == .messages) {
                    activeTab = .messages
                }
                Spacer()
                NavbarButton(tab: .profile, isActive: activeTab == .profile) {
                    activeTab = .profile
                }
                Spacer()
            }
        }
            .frame(maxWidth: .infinity, maxHeight: 68)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: .black.opacity(0.12), radius: 4)
            .padding(.horizontal, 16)
    }
}

#Preview {
    RootNavbar(activeTab: .constant(.dashboard))
}
