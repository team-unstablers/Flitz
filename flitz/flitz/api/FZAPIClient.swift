//
//  FZAPIClient.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/4/24.
//

import Foundation

import Alamofire

class FZAPIClient {
    var context: FZAPIContext
    
    init(context: FZAPIContext) {
        self.context = context
    }
        
    func request<Parameters: Encodable & Sendable, Response>(
        to endpoint: FZAPIEndpoint,
        expects type: Response.Type,
        method: HTTPMethod = .get,
        parameters: Parameters = Dictionary<String, String>(),
        requiresAuth: Bool = true
    ) async throws -> Response where Response: Decodable & Sendable {
        let url = endpoint.url(for: context.host.rawValue)
        
        let headers: HTTPHeaders? = (requiresAuth) ? [
            "Authorization": "Bearer \(context.token ?? "")"
        ] : nil
        
        let response = AF.request(url,
                                  method: method,
                                  parameters: parameters,
                                  encoder: method == .get ? URLEncodedFormParameterEncoder.default : JSONParameterEncoder.default,
                                  headers: headers)
            .validate()
        
        
        if type == Ditch.self {
            let response = await response.serializingString().response
            if let error = response.error {
                throw error
            }
            
            return Ditch() as! Response
        } else {
            let response = await response.serializingDecodable(type).response
            
            guard let value = response.value else {
                let error = response.error!
                let underlyingError = error.underlyingError
                
                throw error
            }
            
            return value
        }
    }
    
    func signup(with credentials: FZCredentials) async throws {
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
    
    func fetchUser(id: String) async throws -> FZUser {
        return try await self.request(to: .user(id: id), expects: FZUser.self)
    }
    
    func cards() async throws -> Paginated<FZSimpleCard> {
        return try await self.request(to: .cards, expects: Paginated<FZSimpleCard>.self)
    }
    
    func receivedCards() async throws -> Paginated<FZCardDistribution> {
        return try await self.request(to: .cardsDistribution, expects: Paginated<FZCardDistribution>.self)
    }
    
    func markAsLike(which distributionId: String) async throws {
        _ = try await self.request(to: .like(distributionId: distributionId), expects: Ditch.self, method: .put)
    }
    
    func markAsDislike(which distributionId: String) async throws {
        _ = try await self.request(to: .dislike(distributionId: distributionId), expects: Ditch.self, method: .put)
    }
    
    func card(by id: String) async throws -> FZCard {
        return try await self.request(to: .card(id: id), expects: FZCard.self)
    }
    
    func setCardAsMain(which cardId: String) async throws {
        _ = try await self.request(to: .setCardAsMain(id: cardId), expects: Ditch.self, method: .put)
    }
    
    func createCard() async throws -> FZCard {
        return try await self.request(to: .cards, expects: FZCard.self, method: .post)
    }
    
    func patchCard(which card: FZCard) async throws -> FZCard {
        guard card.content.isReadyToPublish else {
            throw FZAPIError.assertionFailure(message: "퍼블리싱 가능 상태가 아닌 카드를 업로드하려 했습니다")
        }
        
        return try await self.request(to: .card(id: card.id),
                                      expects: FZCard.self,
                                      method: .patch,
                                      parameters: card)
    }
    
    func uploadCardAsset(of cardId: String, asset: Data, type: AssetCreationType) async throws -> FZCardAssetReference {
        let url = FZAPIEndpoint.cardAssetReferences(id: cardId).url(for: context.host.rawValue)
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(context.token!)"
        ]
        
        let response = try await AF.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(asset, withName: "file", fileName: type.defaultFileName, mimeType: type.mimeType)
        }, to: url, method: .post, headers: headers)
            .validate()
            .serializingDecodable(FZCardAssetReference.self)
            .response
        
        guard let value = response.value else {
            let error = response.error!
            let underlyingError = error.underlyingError
            
            throw error
        }
        
        return value
    }
    
    /// 알아서 모든 로컬 에셋을 업로드합니다
    func uploadCardAssets(of card: FZCard) async throws {
        try await card.content.background?.uploadToServer(using: self, cardId: card.id)
        
        for element in card.content.elements {
            if let imageElement = element as? Flitz.Image {
                try await imageElement.source.uploadToServer(using: self, cardId: card.id)
            }
        }
    }
    
    
    func startWaveDiscovery() async throws -> WaveDiscoverySessionInfo {
        return try await self.request(to: .waveDiscoveryStart, expects: WaveDiscoverySessionInfo.self, method: .post)
    }
    
    func stopWaveDiscovery() async throws {
        _ = try await self.request(to: .waveDiscoveryEnd, expects: Ditch.self, method: .post)
    }
    
    func reportWaveDiscovery(_ args: ReportWaveDiscoveryArgs) async throws {
        _ = try await self.request(to: .waveReportDiscovery,
                                   expects: Ditch.self,
                                   method: .post,
                                   parameters: args)
    }
}

fileprivate extension Flitz.ImageSource {
    mutating func uploadToServer(using client: FZAPIClient, cardId: String) async throws {
        guard case .uiImage(let image) = self else {
            return
        }
        
        guard let jpeg = image.jpegData(compressionQuality: 0.92) else {
            fatalError("JPEG 저장 실패")
        }
        
        let assetRef = try await client.uploadCardAsset(of: cardId, asset: jpeg, type: .image)
        
        self = .origin(assetRef.id, URL(string: assetRef.public_url)!)
    }
}
