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
                WaveSafetyZoneSettingsSection()
                    .padding(.horizontal, 16)
                
                FZPageSectionDivider()
                

                ContactsBlockSettingsSection()
                    .padding(.horizontal, 16)
            }
        }
        .navigationTitle(NSLocalizedString("ui.safety.protection_settings.page_title", comment: "사용자 보호 기능 설정"))
    }
}

#Preview {
    ProtectionSettingsScreen()
        .environmentObject(RootAppState())
}
