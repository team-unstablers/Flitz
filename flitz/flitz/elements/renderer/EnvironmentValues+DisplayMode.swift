//
//  EnvironmentValues+DisplayMode.swift
//  reazure
//
//  Created by Gyuhwan Park on 11/30/24.
//

import SwiftUI

private struct FZDisplayModeKey: EnvironmentKey {
    static let defaultValue: FZDisplayMode = .default
}

extension EnvironmentValues {
    var fzDisplayMode: FZDisplayMode {
        get { self[FZDisplayModeKey.self] }
        set { self[FZDisplayModeKey.self] = newValue }
    }
}
