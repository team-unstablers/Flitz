//
//  AppIntroScreen.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/14/25.
//

import SwiftUI

struct AppIntroScreen: View {
    @EnvironmentObject
    var authPhaseState: AuthPhaseState
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                Spacer()
                
                FlitzLogo()
                    .frame(width: 200, height: 200)
                
                Spacer()
                
                VStack {
                    FZButton(size: .large) {
                        authPhaseState.navState.append(.signUp)
                    } label: {
                        Text("회원가입")
                            .font(.fzMain)
                            .semibold()
                    }
                    
                    FZButton(palette: .clear, size: .large) {
                        authPhaseState.navState.append(.signIn)
                    } label: {
                        Text("로그인")
                            .font(.fzMain)
                            .semibold()
                    }
                }
                .padding(16)
                .padding(.bottom, 40)
            }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        
        }
    }
}

#Preview {
    AppIntroScreen()
}
