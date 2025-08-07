//
//  EnvironmentValues+ConversationId.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/8/25.
//

import SwiftUI

struct ConversationIdKey: EnvironmentKey {
    static let defaultValue = ""
}

extension EnvironmentValues {
    var conversationId: String {
        get { self[ConversationIdKey.self] }
        set { self[ConversationIdKey.self] = newValue }
    }
}