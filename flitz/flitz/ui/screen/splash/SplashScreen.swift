//
//  SplashScreen.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/4/24.
//

import SwiftUI

struct SplashScreen: View {
    var body: some View {
        VStack {
            FlitzLogo()
                .frame(maxWidth: 200)
                .padding(32)
        }
    }
}

#Preview {
    SplashScreen()
}
