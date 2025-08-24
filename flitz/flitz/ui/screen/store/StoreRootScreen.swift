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
            Text("준비 중인 기능입니다")
                .font(.heading2)
                .bold()
                .foregroundStyle(Color.Grayscale.gray8)
            
            Text("조금만 더 기다려 주세요.\n곧 멋진 기능으로 찾아뵐게요!")
                .multilineTextAlignment(.center)
                .font(.main)
                .foregroundStyle(Color.Grayscale.gray7)
        }
    }
}
