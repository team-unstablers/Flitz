//
//  FZAPIClient+Auth.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/1/25.
//

extension FZAPIClient {
    func startRegistration(_ args: StartRegistrationSessionArgs) async throws -> RegistrationSession {
        try await self.request(to: .startRegistration,
                               expects: RegistrationSession.self,
                               method: .post,
                               parameters: args,
                               requiresAuth: false)
    }
    
    func registrationStartPhoneVerification(_ args: RegistrationStartPhoneVerificationArgs) async throws -> SimpleResponse {
        try await self.request(to: .registrationStartPhoneVerification,
                               expects: SimpleResponse.self,
                               method: .post,
                               parameters: args,
                               requiresAuth: true)
    }
    
    func registrationCompletePhoneVerification(_ args: RegistrationCompletePhoneVerificationArgs) async throws -> SimpleResponse {
        try await self.request(to: .registrationCompletePhoneVerification,
                               expects: SimpleResponse.self,
                               method: .post,
                               parameters: args,
                               requiresAuth: true)
    }
    
    func registrationUsernameAvailability(username: String) async throws -> SimpleResponse {
        try await self.request(to: .registrationUsernameAvailability,
                               expects: SimpleResponse.self,
                               method: .post,
                               parameters: UsernameAvailabilityArgs(username: username),
                               requiresAuth: true)
    }
    
    func completeRegistration(with credentials: UserRegistrationArgs) async throws -> FZUserToken {
        try await self.request(to: .completeRegistration,
                               expects: FZUserToken.self,
                               method: .post,
                               parameters: credentials,
                               requiresAuth: true)
    }
   
}
