//
//  AppMain.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/4/24.
//

import SwiftUI

struct FlitzAppMain: View {
    
    @State
    var phase: AppPhase = .splash
    
    var body: some View {
        if phase == .splash {
            SplashPhase(phase: $phase)
        } else if phase == .auth {
            AuthPhase(phase: $phase)
        } else if phase == .main {
            MainPhase()
        }
    }
}
