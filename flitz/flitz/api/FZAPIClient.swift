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
        to url: URL,
        expects type: Response.Type,
        method: HTTPMethod = .get,
        parameters: Parameters = Dictionary<String, String>(),
        requiresAuth: Bool = true
    ) async throws -> Response where Response: Decodable & Sendable {
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
 
        
    func request<Parameters: Encodable & Sendable, Response>(
        to endpoint: FZAPIEndpoint,
        expects type: Response.Type,
        method: HTTPMethod = .get,
        parameters: Parameters = Dictionary<String, String>(),
        requiresAuth: Bool = true
    ) async throws -> Response where Response: Decodable & Sendable {
        let url = endpoint.url(for: context.host.rawValue)
        
        return try await self.request(to: url,
                                      expects: type,
                                      method: method,
                                      parameters: parameters,
                                      requiresAuth: requiresAuth)
    }
    
    func nextPage<T: Codable>(_ pagination: Paginated<T>) async throws -> Paginated<T>? {
        guard let next = pagination.next,
              let url = URL(string: next) else {
            return nil
        }
        
        return try await self.request(to: url,
                                      expects: Paginated<T>.self)
    }
    
    func prevPage<T: Codable>(_ pagination: Paginated<T>) async throws -> Paginated<T>? {
        guard let next = pagination.next,
              let url = URL(string: next) else {
            return nil
        }
        
        return try await self.request(to: url,
                                      expects: Paginated<T>.self)
    }
}
