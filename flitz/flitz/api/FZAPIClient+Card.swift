//
//  FZAPIClient+Card.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/1/25.
//

import Foundation
import Alamofire

extension FZAPIClient {
    func cards() async throws -> Paginated<FZCard> {
        return try await self.request(to: .cards, expects: Paginated<FZCard>.self)
    }
    
    func receivedCards() async throws -> Paginated<FZCardDistribution> {
        return try await self.request(to: .cardsDistribution, expects: Paginated<FZCardDistribution>.self)
    }
    
    func favoritedCards() async throws -> Paginated<FZCardFavoriteItem> {
        return try await self.request(to: .cardFavorites, expects: Paginated<FZCardFavoriteItem>.self)
    }
    
    func deleteFavoriteCard(by id: String) async throws {
        _ = try await self.request(to: .cardFavorite(id: id), expects: Ditch.self, method: .delete)
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
    
    func flagCard(id: String, args: FlagCardArgs) async throws -> SimpleResponse {
        return try await self.request(to: .flagCard(id: id),
                                      expects: SimpleResponse.self,
                                      method: .post,
                                      parameters: args)
    }
    
    
    func setCardAsMain(which cardId: String) async throws {
        _ = try await self.request(to: .setCardAsMain(id: cardId), expects: Ditch.self, method: .put)
    }
    
    func createCard() async throws -> FZCard {
        return try await self.request(to: .cards, expects: FZCard.self, method: .post)
    }
    
    func deleteCard(by id: String) async throws {
        _ = try await self.request(to: .card(id: id), expects: Ditch.self, method: .delete)
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
    @MainActor
    func uploadCardAssets(of card: FZCard) async throws {
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                try? await card.content.background?.uploadToServer(using: self, cardId: card.id)
            }
            
            for element in card.content.elements {
                if let imageElement = element as? Flitz.Image {
                    try? await imageElement.source.uploadToServer(using: self, cardId: card.id)
                }
            }
        }
    }
}


fileprivate extension Flitz.ImageSource {
    
    @MainActor
    mutating func uploadToServer(using client: FZAPIClient, cardId: String) async throws {
        guard case .uiImage(let image) = self else {
            return
        }
        
        let resizedImage = image.resize2(maxWidth: 1280, maxHeight: 1280)
        
        guard let jpeg = resizedImage.jpegData(compressionQuality: 0.91) else {
            // ?????
            fatalError("JPEG 저장 실패")
        }
        
        let assetRef = try await client.uploadCardAsset(of: cardId, asset: jpeg, type: .image)
        self = .origin(assetRef.id, URL(string: assetRef.public_url)!)
    }
    
}
