//
//  FZColors+Brand.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/14/24.
//

import SwiftUI

extension Color {
    struct Brand {
        static let main0 = Color(r8: 51, g8: 51, b8: 51, a: 1)
        
        /// Main Orange 0
        static let orange0 = Color(hex: 0xFEAF92)
        /// Main Blue 0
        static let blue0 = Color(hex: 0xCDE7FF)
        /// Main Yellow 0
        static let yellow0 = Color(hex: 0xFFEDA4)
        /// Main Green 0
        static let green0 = Color(hex: 0xA9D2A5)
        /// Main Gray 0
        static let gray0 = Color(hex: 0xF0EEE9)
        /// Main Black 0
        static let black0 = Color(hex: 0x090909)
    }
}

#Preview("Brand Colors") {
    HStack {
        Group {
            Color.Brand.orange0
            Color.Brand.blue0
            Color.Brand.yellow0
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .frame(width: 64, height: 64)
    }
    HStack {
        Group {
            Color.Brand.green0
            Color.Brand.gray0
            Color.Brand.black0
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .frame(width: 64, height: 64)
    }
}
