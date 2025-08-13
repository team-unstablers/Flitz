//
//  FZAPIClient+Auth.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/1/25.
//

extension FZAPIClient {
    func signup(with credentials: UserRegistrationArgs) async throws {
        try await self.request(to: .register,
                               expects: Ditch.self,
                               method: .post,
                               parameters: credentials,
                               requiresAuth: false)
    }
    
    func authorize(with credentials: FZCredentials) async throws -> FZUserToken {
        let response = try await self.request(to: .token,
                                              expects: FZUserToken.self,
                                              method: .post,
                                              parameters: credentials,
                                              requiresAuth: false)
        
        return response
    }
    
}
