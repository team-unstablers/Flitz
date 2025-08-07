//
//  Environment+UserId.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/6/25.
//

import SwiftUI

struct DirectMessageParticipantsEnvironmentKey: EnvironmentKey {
    static let defaultValue: [DirectMessageParticipant] = []
}

extension EnvironmentValues {
    var directMessageParticipants: [DirectMessageParticipant] {
        get { self[DirectMessageParticipantsEnvironmentKey.self] }
        set { self[DirectMessageParticipantsEnvironmentKey.self] = newValue }
    }
}
