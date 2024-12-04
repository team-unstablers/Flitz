//
//  RootAppState.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/4/24.
//

import Foundation
import SwiftUI

class RootAppState: ObservableObject {
    @Published
    var client: FZAPIClient = FZAPIClient(context: .load())
    
    @Published
    var waveCommunicator: FlitzWaveCommunicator!
    
    @Published
    var profile: FZUser?
    
    init() {
        self.waveCommunicator = FlitzWaveCommunicator(with: self.client)
    }
    
    
    func loadProfile() {
        Task {
            do {
                let profile = try await self.client.fetchUser(id: "self")
                
                DispatchQueue.main.async {
                    self.profile = profile
                }
            } catch {
                print(error)
            }
        }
    }
}
