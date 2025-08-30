//
//  FZAPIClient+Auth.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/1/25.
//

extension FZAPIClient {
    func authorize(with credentials: FZCredentials) async throws -> FZUserToken {
        let response = try await self.request(to: .token,
                                              expects: FZUserToken.self,
                                              method: .post,
                                              parameters: credentials,
                                              requiresAuth: false)
        
        return response
    }
    
    func refreshToken(_ args: RefreshTokenArgs) async throws -> FZUserToken {
        let response = try await self.request(to: .refreshToken,
                                              expects: FZUserToken.self,
                                              method: .post,
                                              parameters: args,
                                              requiresAuth: false)
        
        return response
    }
    
    func requestPasswordReset(_ args: ResetPasswordRequestArgs) async throws -> SimpleResponse {
        try await self.request(to: .resetPasswordRequest,
                               expects: SimpleResponse.self,
                               method: .post,
                               parameters: args,
                               requiresAuth: false)
    }
    
    func confirmPasswordReset(_ args: ResetPasswordConfirmArgs) async throws -> SimpleResponse {
        try await self.request(to: .resetPasswordConfirm,
                               expects: SimpleResponse.self,
                               method: .post,
                               parameters: args,
                               requiresAuth: false)
    }
}
