//
//  EnvironmentValues+DisplayMode.swift
//  reazure
//
//  Created by Gyuhwan Park on 11/30/24.
//

import SwiftUI

private struct FZAssetsLoaderKey: EnvironmentKey {
    static let defaultValue: AssetsLoader = .global
}

extension EnvironmentValues {
    var fzAssetsLoader: AssetsLoader {
        get { self[FZAssetsLoaderKey.self] }
        set { self[FZAssetsLoaderKey.self] = newValue }
    }
}
