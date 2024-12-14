//
//  RootNavbar.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/5/24.
//

import SwiftUI

struct NavbarButton: View {
    var icon: String
    var label: String
    
    var isActive: Bool = false
    
    var handler: () -> Void
    
    var body: some View {
        Button {
            handler()
        } label: {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .frame(width: 20, height: 20)
                Text(label)
                    .font(.system(size: 12))
                    .bold(isActive)
            }
            .foregroundStyle(isActive ? Color(hex: 0xFFC107) : Color(hex: 0xBDBDBD))
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
                NavbarButton(icon: "house", label: "홈", isActive: activeTab == .dashboard) {
                    activeTab = .dashboard
                }
                Spacer()
                NavbarButton(icon: "arrow.2.circlepath", label: "웨이브", isActive: activeTab == .exchangedCards) {
                    activeTab = .exchangedCards
                }
                Spacer()
                NavbarButton(icon: "message", label: "메시지", isActive: activeTab == .messages) {
                    activeTab = .messages
                }
                Spacer()
                NavbarButton(icon: "person", label: "내 프로필", isActive: activeTab == .profile) {
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
