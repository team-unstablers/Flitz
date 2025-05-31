//
//  FlitzLogo.swift
//  Flitz
//
//  Created by Gyuhwan Park on 4/25/25.
//

import SwiftUI

struct FlitzLogo: View {
    var body: some View {
        Image("FlitzLogo")
            .resizable()
            .scaledToFit()
    }
}

#Preview {
    FlitzLogo()
        .frame(width: 200, height: 200)
        .padding()
}
