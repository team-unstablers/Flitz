//
//  FZAPIClient+User.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/1/25.
//

import Foundation

import Alamofire

extension FZAPIClient {
    func fetchUser(id: String) async throws -> FZUser {
        return try await self.request(to: .user(id: id), expects: FZUser.self)
    }
    
    func fetchSelf() async throws -> FZSelfUser {
        return try await self.request(to: .user(id: "self"), expects: FZSelfUser.self)
    }
    
    func patchSelf(_ args: PatchSelfArgs) async throws -> FZUser {
        return try await self.request(to: .user(id: "self"),
                                      expects: FZUser.self,
                                      method: .patch,
                                      parameters: args)
    }
    
    func setProfileImage(file: Data, fileName: String, mimeType: String) async throws -> DirectMessage {
        let url = FZAPIEndpoint.selfProfileImage.url(for: context.host.rawValue)
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(context.token!)"
        ]
        
        let response = await AF.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(file, withName: "file", fileName: fileName, mimeType: mimeType)
        }, to: url, method: .post, headers: headers)
            .validate()
            .serializingDecodable(DirectMessage.self)
            .response
        
        guard let value = response.value else {
            throw response.error!
        }
        
        return value
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
