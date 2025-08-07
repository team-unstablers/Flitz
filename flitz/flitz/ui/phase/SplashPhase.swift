//
//  AuthPhase.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/4/24.
//

import SwiftUI

struct SplashPhase: View {
    @Binding
    var phase: AppPhase
    
    var body: some View {
        SplashScreen()
            .onAppear {
                transitionToNextPhase()
            }
    }
    
    func transitionToNextPhase() {
        let context = FZAPIContext.load()
        
        guard let _ = context.token else {
            phase = .auth
            return
        }
        
        phase = .main
    }
    
}
