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
                DummyCardView()
                VStack {
                    Text("제목 없는 카드")
                        .font(.heading2)
                        .bold()
                    HStack {
                        FZButton(style: .secondary) {
                            
                        } label: {
                            Text("편집하기")
                        }
                        
                        FZButton(style: .secondary) {
                            
                        } label: {
                            Text("다른 카드로 교체")
                        }
                    }
                }
                .padding(.bottom, 32)
            }
            .navigationTitle("현재 교환 중인 카드")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Button {
                            
                        } label: {
                            Text("카드아이콘좀그려주세요 ㅠㅠ")
                        }
                        Button {
                            appState.navState.append(.settings)
                        } label: {
                            ProfileImage(
                                url: "https://ppiy.ac/system/accounts/avatars/110/796/233/076/688/314/original/df6e9ebf6bb70ef2.jpg",
                                size: 36
                            )
                        }
                    }
                }
            }
        }
        
    }
}

#Preview {
    ProfileScreen()
        .environmentObject(RootAppState())
}
