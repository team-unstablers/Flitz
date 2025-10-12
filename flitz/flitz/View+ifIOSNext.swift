//
//  View+ifIOSNext.swift
//  Flitz
//
//  Created by Gyuhwan Park on 10/12/25.
//

import SwiftUI

extension View {
    @ViewBuilder
    func ifIOSNext<Content: View>(_ transform: (Self) -> Content) -> some View {
        if #available(iOS 26.0, *) {
            transform(self)
        } else {
            self
        }
    }
}
