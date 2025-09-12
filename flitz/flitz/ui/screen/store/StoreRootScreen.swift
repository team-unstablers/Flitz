//
//  StoreRootScreen.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/25/25.
//

import SwiftUI

struct StoreRootScreen: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("ui.store.coming_soon.title")
                .font(.heading2)
                .bold()
                .foregroundStyle(Color.Grayscale.gray8)
            
            Text("ui.store.coming_soon.description")
                .multilineTextAlignment(.center)
                .font(.main)
                .foregroundStyle(Color.Grayscale.gray7)
        }
    }
}
