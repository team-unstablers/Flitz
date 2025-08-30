//
//  SplashPhase.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/4/24.
//

import SwiftUI

enum AuthNavigationItem: Hashable {
    case signIn
    case signUp
    case findPassword
}


struct AuthPhase: View {
    @Binding
    var phase: AppPhase
    
    @StateObject
    var authPhaseState = AuthPhaseState()
    
    var body: some View {
        if authPhaseState.navState.last == .signUp {
            SignUpScreen {
                phase = .main
            }
                .environmentObject(authPhaseState)
        } else {
            NavigationStack(path: $authPhaseState.navState) {
                AppIntroScreen()
                    .navigationDestination(for: AuthNavigationItem.self) { item in
                        switch item {
                        case .signIn:
                            SignInScreen { context in
                                context.save()
                                RootAppState.shared.reloadContext()
                                
                                withAnimation {
                                    phase = .main
                                }
                            }
                        case .signUp:
                            EmptyView()
                        case .findPassword:
                            FindPasswordScreen()
                        default:
                            EmptyView()
                        }
                    }
            }
            .environmentObject(authPhaseState)
        }
        /*
         */
    }
}
