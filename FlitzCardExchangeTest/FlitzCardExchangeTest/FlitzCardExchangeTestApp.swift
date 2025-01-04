//
//  FlitzCardExchangeTestApp.swift
//  FlitzCardExchangeTest
//
//  Created by Gyuhwan Park on 12/3/24.
//

import SwiftUI

@main
struct FlitzCardExchangeTestApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(BeaconCommunicator.shared)
        }
    }
}
