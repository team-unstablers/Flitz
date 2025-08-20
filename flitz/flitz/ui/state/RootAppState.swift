//
//  RootAppState.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/4/24.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class RootAppState: ObservableObject {
    static let shared = RootAppState()
    
    @Published
    var client: FZAPIClient = FZAPIClient(context: .load())
    
    @Published
    var currentTab: RootTab = .wave
    
    @Published
    var navState: [RootNavigationItem] = []
    
    @Published
    var currentModal: RootModalItem? = nil
    
    @Published
    var waveCommunicator: WaveCommunicator!
    
    @Published
    var waveActive: Bool = false
    
    @Published
    var profile: FZSelfUser?
    
    
    @Published
    var assertionFailureReason: AssertionFailureReason? = nil
    
    var conversationUpdated = PassthroughSubject<Void, Never>()
    
    init() {
        self.waveCommunicator = WaveCommunicator(with: self.client)
        self.waveCommunicator.delegate = self
    }
    
    func reloadContext() {
        Task {
            try await self.waveCommunicator.stop()
        }
        
        self.client = FZAPIClient(context: .load())
        self.waveCommunicator = WaveCommunicator(with: self.client)
        self.waveCommunicator.delegate = self

        // Reset the profile
        self.profile = nil
        
        // Reload the profile
        loadProfile()
        
        // Update APNS token if available
        updateAPNSToken()
        
        Task {
            try await self.waveCommunicator.recoverState()
        }
    }
    
    func loadProfile() {
        Task {
            do {
                let profile = try await self.client.fetchSelf()
                self.profile = profile
                
                await ContactsBlockerTask.updateEnabled()
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
    
    func logout() {
        FZAPIContext.reset()
        
        for key in UserDefaults.standard.dictionaryRepresentation().keys {
            UserDefaults.standard.removeObject(forKey: key.description)
        }
        
        self.client = FZAPIClient(context: .load())
        
        // kill self
        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            exit(0)
        }
    }
}

extension RootAppState: @preconcurrency WaveCommunicatorDelegate {
    func communicator(_ communicator: WaveCommunicator, didStart sessionId: String) {
        self.waveActive = true
    }
    
    func communicator(_ communicator: WaveCommunicator, didStop sessionId: String) {
        self.waveActive = false
    }
    
}
