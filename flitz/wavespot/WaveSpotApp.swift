//
//  Flitz_WaveSpotApp.swift
//  Flitz WaveSpot
//
//  Created by Gyuhwan Park on 9/13/25.
//

import SwiftUI
import AppClip

@main
struct WaveSpotApp: App {
    var body: some Scene {
        WindowGroup {
            AppRoot()
                .preferredColorScheme(.light)
                .font(.main)
        }
    }
}
