//
//  flitzApp.swift
//  flitz
//
//  Created by Gyuhwan Park on 12/4/24.
//

import SwiftUI

@main
struct FlitzApp: App {
    @UIApplicationDelegateAdaptor
    private var appDelegate: AppDelegate

    var body: some Scene {
        WindowGroup {
            FlitzAppMain()
                .colorScheme(.light)
                .tintColor(Color.Brand.main0)
                .font(.fzMain)
        }
    }
}
