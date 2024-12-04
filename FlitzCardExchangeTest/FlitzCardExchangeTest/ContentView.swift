//
//  ContentView.swift
//  FlitzCardExchangeTest
//
//  Created by Gyuhwan Park on 12/3/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject
    var beaconCommunicator: BeaconCommunicator
    
    @State
    var major: String = ""
    
    @State
    var minor: String = ""
    
    var body: some View {
        VStack {
            VStack {
                ForEach(0..<beaconCommunicator.logs.count, id: \.self) { i in
                    Text(beaconCommunicator.logs[i])
                }
            }
            Spacer()
            TextField("id", text: $beaconCommunicator.id)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            
            Button("sanity check") {
                beaconCommunicator.sanityCheck()
            }
            
            Button("start listening") {
                beaconCommunicator.startListening()
            }
            Button("start advertise") {
                beaconCommunicator.startAdvertising()
            }
        }
        .onChange(of: major) {
            beaconCommunicator.identity.major = UInt16($0) ?? 0
        }
        .onChange(of: minor) {
            beaconCommunicator.identity.minor = UInt16($0) ?? 0
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
