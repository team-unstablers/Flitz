//
//  MainPhase.swift
//  Flitz
//
//  Created by Gyuhwan Park on 9/13/25.
//

import SwiftUI

struct MainPhase: View {
    static let TABS = [
        FZTab(id: "cards", title: "카드"),
        FZTab(id: "board", title: "게시판")
    ]
    
    @State
    var selectedTabId: String = Self.TABS.first!.id
    
    var body: some View {
        VStack(spacing: 0) {
            MainTitlebar {}
            FZInlineTab(tabs: Self.TABS, selectedTabId: $selectedTabId)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            
            if selectedTabId == "cards" {
                Rectangle()
            } else if selectedTabId == "board" {
                Rectangle().foregroundColor(.green)
            }
        }
    }
}

#if DEBUG
#Preview {
    MainPhase()
}
#endif
