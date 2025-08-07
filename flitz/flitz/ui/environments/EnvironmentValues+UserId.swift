//
//  Environment+UserId.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/6/25.
//

import SwiftUI

struct UserIdKey: EnvironmentKey {
    static let defaultValue = "__UNKNOWN__"
}

extension EnvironmentValues {
    var userId: String {
        get { self[UserIdKey.self] }
        set { self[UserIdKey.self] = newValue }
    }
}
