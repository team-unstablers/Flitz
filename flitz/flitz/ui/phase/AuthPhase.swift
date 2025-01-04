//
//  SplashPhase.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/4/24.
//

import SwiftUI

struct AuthPhase: View {
    @Binding
    var phase: AppPhase
    
    var body: some View {
        SignInScreen { context in
            context.save()
            
            withAnimation {
                phase = .main
            }
        }
    }
}
