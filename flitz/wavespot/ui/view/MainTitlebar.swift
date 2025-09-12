//
//  MainTitlebar.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/31/24.
//

import SwiftUI

struct MainTitlebar<Content: View>: View {
    @ViewBuilder
    var asideContent: () -> Content
    
    var body: some View {
        HStack(spacing: 0) {
            Image("WaveSpotLogo")
                .resizable()
                .scaledToFit()
                .frame(height: 30)
            Spacer()
            HStack(spacing: 12) {
                asideContent()
            }
        }
        .padding(.leading, 24)
        .padding(.trailing, 24)
        .frame(maxWidth: .infinity, maxHeight: 72)
    }
}

#Preview {
    VStack {
        Text("Titlebar")
        MainTitlebar {
        }
    }
}
