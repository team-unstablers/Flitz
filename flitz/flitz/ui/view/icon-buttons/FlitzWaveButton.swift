//
//  FlitzWaveButton.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/31/24.
//
import SwiftUI

struct FlitzWaveButton: View {
    var isOn: Bool
    var toggleAction: () -> Void = { }
    
    var body: some View {
        Button(action: toggleAction) {
            Image(isOn ? "WaveOn" : "WaveOff")
                .resizable()
                .scaledToFit()
                .frame(height: 36)
        }
    }
}

#Preview {
    Text("FlitzWaveButton")
    HStack {
        FlitzWaveButton(isOn: false)
        FlitzWaveButton(isOn: true)
    }
    
}
