//
//  APIClient.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 11/29/24.
//

import Foundation

import Alamofire

enum FZAPIError: LocalizedError {
    case assertionFailure(message: String)
}

struct FZAPIEndpoint: RawRepresentable {
    var rawValue: String
    
    init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    static let token = FZAPIEndpoint(rawValue: "/auth/token")
    
    // user start
    static func user(id: String) -> FZAPIEndpoint {
        return FZAPIEndpoint(rawValue: "/users/\(id)/")
    }
    // user end
    
    // card start
    static let cards = FZAPIEndpoint(rawValue: "/cards/")

    static func card(id: String) -> FZAPIEndpoint {
        return FZAPIEndpoint(rawValue: "/cards/\(id)/")
    }
    
    static func cardAssetReferences(id: String) -> FZAPIEndpoint {
        return FZAPIEndpoint(rawValue: "/cards/\(id)/asset-references/")
    }
    // card end
    
    func urlString(for server: String) -> String {
        return "\(server)\(self.rawValue)"
    }
    
    func url(for server: String) -> URL {
        return URL(string: self.urlString(for: server))!
    }
}

struct FZAPIContext: Codable {
    var baseURL: String = "http://cheese-mbpr14.local:8000"
    var token: String?
    
    static var stored: FZAPIContext? {
        get {
            guard let contextJSON = UserDefaults.standard.string(forKey: "api_context") else {
                return nil
            }
            
            return try? JSON.parse(contextJSON, to: FZAPIContext.self)
        }
        set {
            UserDefaults.standard.set(try? JSON.stringify(newValue), forKey: "api_context")
        }
    }
}



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
        let url = endpoint.url(for: context.baseURL)
        
        let headers: HTTPHeaders? = (requiresAuth) ? [
            "Authorization": "Bearer \(context.token!)"
        ] : nil
        
        let response = await AF.request(url,
                                        method: method,
                                        parameters: parameters,
                                        encoder: method == .get ? URLEncodedFormParameterEncoder.default : JSONParameterEncoder.default,
                                        headers: headers)
            .validate()
            .serializingDecodable(type)
            .response
        
        guard let value = response.value else {
            let error = response.error!
            let underlyingError = error.underlyingError
            
            throw error
        }
        
        return value
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
    
    func card(by id: String) async throws -> FZCard {
        return try await self.request(to: .card(id: id), expects: FZCard.self)
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
        let url = FZAPIEndpoint.cardAssetReferences(id: cardId).url(for: context.baseURL)
        
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
    
}


fileprivate extension String {
    func sanitizeServerAddress() -> String {
        var server = self
        if server.hasPrefix("https://") {
            server.removeFirst("https://".count)
        } else if server.hasPrefix("http://") {
            server.removeFirst("http://".count)
        } else if server.hasPrefix("wss://") {
            server.removeFirst("wss://".count)
        } else if server.hasPrefix("ws://") {
            server.removeFirst("ws://".count)
        }
        
        if server.hasSuffix("/") {
            server.removeLast()
        }
        
        return server
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
