//
//  View+AppState.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/10/25.
//

import SwiftUI

extension View {
    @ViewBuilder
    func onScenePhase(_ desired: ScenePhase, immediate: Bool = false, perform action: @escaping () -> Void) -> some View {
        self.modifier(OnScenePhaseModifier(desired: desired, immediate: immediate, action: action))
    }
}

struct OnScenePhaseModifier: ViewModifier {
    let desired: ScenePhase
    let immediate: Bool
    let action: () -> Void
    
    @Environment(\.scenePhase)
    private var scenePhase
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                if immediate && desired == .active {
                    action()
                }
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == desired {
                    action()
                }
            }
    }
}
