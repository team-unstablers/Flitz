//
//  View+ifIOSNext.swift
//  Flitz
//
//  Created by Gyuhwan Park on 10/12/25.
//

import SwiftUI

extension View {
    @ViewBuilder
    func ifIOSNext<Transformed: View, ElseTransformed: View>(
        @ViewBuilder _ transform: (Self) -> Transformed,
        @ViewBuilder else elseTransform: (Self) -> ElseTransformed
    ) -> some View {
        if #available(iOS 26.0, *) {
            transform(self)
        } else {
            elseTransform(self)
        }
    }
    
    @ViewBuilder
    func ifIOSNext<Transformed: View>(
        @ViewBuilder _ transform: (Self) -> Transformed
    ) -> some View {
        self.ifIOSNext(transform, else: { $0 })
    }
}
