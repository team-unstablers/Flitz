//
//  FZAPIClient+User.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/1/25.
//

extension FZAPIClient {
    func fetchUser(id: String) async throws -> FZUser {
        return try await self.request(to: .user(id: id), expects: FZUser.self)
    }
    
    func updateAPNSToken(_ token: String) async throws {
        struct APNSTokenRequest: Encodable {
            let apns_token: String
        }
        
        let parameters = APNSTokenRequest(apns_token: token)
        
        _ = try await self.request(to: .apnsToken,
                                   expects: Ditch.self,
                                   method: .put,
                                   parameters: parameters)
    }
}
