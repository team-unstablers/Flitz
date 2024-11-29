//
//  ContentView.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 11/23/24.
//

import SwiftUI

struct ContentView: View {
    @State
    var phase: Bool = FZAPIContext.stored != nil

    
    var body: some View {
        if !phase {
            TestSignInView(phase: $phase)
        } else {
            TestView()
        }
    }
}

#Preview {
    ContentView()
}
