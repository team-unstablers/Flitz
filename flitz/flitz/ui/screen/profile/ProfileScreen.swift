//
//  ProfileScreen.swift
//  Flitz
//
//  Created by Gyuhwan Park on 1/4/25.
//

import SwiftUI

struct ProfileScreen: View {
    @EnvironmentObject
    var appState: RootAppState
    
    var body: some View {
        NavigationView {
            VStack {
                /*
                DummyCardView()

                 */
                
                CardManagerView()
            }
            .navigationTitle("내 카드")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        appState.navState.append(.settings)
                    } label: {
                        SelfProfileImage(size: 36)
                    }
                }
            }
        }
            .onAppear {
                appState.loadProfile()
            }
    }
}

#Preview {
    ProfileScreen()
        .environmentObject(RootAppState())
}
