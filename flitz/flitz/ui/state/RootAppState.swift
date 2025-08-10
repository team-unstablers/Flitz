//
//  RootAppState.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/4/24.
//

import Foundation
import SwiftUI
import Combine

class RootAppState: ObservableObject {
    static let shared = RootAppState()
    
    @Published
    var client: FZAPIClient = FZAPIClient(context: .load())
    
    @Published
    var currentTab: RootTab = .wave
    
    @Published
    var navState: [RootNavigationItem] = []
    
    @Published
    var userModalProfileId: String? = nil
    
    @Published
    var waveCommunicator: FlitzWaveCommunicator!
    
    @Published
    var waveActive: Bool = false
    
    @Published
    var profile: FZSelfUser?
    
    @Published
    var assertionFailureReason: AssertionFailureReason? = nil
    
    var conversationUpdated = PassthroughSubject<Void, Never>()
    
    init() {
        self.waveCommunicator = FlitzWaveCommunicator(with: self.client)
    }
    
    
    func loadProfile() {
        Task {
            do {
                let profile = try await self.client.fetchSelf()
                
                DispatchQueue.main.async {
                    self.profile = profile
                }
            } catch {
                print(error)
            }
        }
    }
    
    func updateAPNSToken() {
        Task {
            do {
                guard let token = await AppDelegate.apnsToken else {
                    return
                }
                try await self.client.updateAPNSToken(token)
            } catch {
                print(error)
            }
        }
    }
}
