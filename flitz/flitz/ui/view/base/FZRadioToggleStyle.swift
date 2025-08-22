//
//  FZCheckboxToggleStyle.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/22/25.
//
import SwiftUI

struct FZRadioToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        // 1
        Button(action: {
            // 2
            configuration.isOn.toggle()
        }, label: {
            HStack(alignment: .center) {
                // 3
                Image(configuration.isOn ? "RadioChecked" : "RadioUnchecked")

                configuration.label
                    .font(.fzMain)
            }
        })
        .buttonStyle(.plain)
    }
}
