//
//  FZTokenRefreshInterceptor.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/24/25.
//

import Foundation
import Alamofire

actor FZTokenRefreshPerformer {
    private var refreshTask: Task<Void, Error>? = nil
    
    weak var client: FZAPIClient? = nil
    
    init(_ client: FZAPIClient?) {
        self.client = client
    }
    
    func refreshToken(force: Bool = false) async throws {
        if let task = refreshTask {
            try await task.value
            return
        }
        
        guard let client = client else {
            return
        }
        
        if !force {
            if !client.context.expired {
                return
            }
        }
        
        let task = Task {
            guard let refreshToken = client.context.refreshToken else {
                throw FZAPIError.noRefreshToken
            }
            
            let args = RefreshTokenArgs(refresh_token: refreshToken)
            let token = try await client.refreshToken(args)
            
            var context = FZAPIContext()
            context.token = token.token
            context.refreshToken = token.refresh_token
            
            guard context.valid() else {
                throw FZAPIError.invalidToken
            }
            
            context.save()
            
            self.client?.context = context
        }
        
        refreshTask = task
        defer { self.refreshTask = nil }
        
        try await task.value
    }
}

final class FZTokenRefreshInterceptor: RequestInterceptor {
    private let logger = createFZOSLogger("FZTokenRefreshInterceptor")
    
    private let performer: FZTokenRefreshPerformer
    private weak var client: FZAPIClient? = nil
    
    init(_ client: FZAPIClient) {
        self.performer = FZTokenRefreshPerformer(client)
        self.client = client
    }
    
    func adapt(_ urlRequest: URLRequest,
               for session: Session,
               completion: @escaping (Result<URLRequest, any Error>) -> Void) {
        
        guard let client = client else {
            completion(.failure(FZAPIError.assertionFailure(message: "FZAPIClient is nil")))
            return
        }
        
        if client.context.expired {
            Task {
                do {
                    try await performer.refreshToken()
                    completion(.success(urlRequest.addingAuthorization(token: client.context.token!)))
                } catch {
                    logger.error("Token refresh failed: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        } else {
            completion(.success(urlRequest.addingAuthorization(token: client.context.token!)))
        }
    }
    
    func retry(_ request: Request,
               for session: Session,
               dueTo error: any Error,
               completion: @escaping (RetryResult) -> Void) {
        
        guard let response = request.task?.response as? HTTPURLResponse,
              response.statusCode == 401 else {
            completion(.doNotRetry)
            return
        }
        
        guard let client = client else {
            completion(.doNotRetryWithError(FZAPIError.assertionFailure(message: "FZAPIClient is nil")))
            return
        }
        
        Task {
            do {
                try await self.performer.refreshToken(force: true)
                completion(.retry)
            } catch {
                logger.error("Token refresh failed: \(error.localizedDescription)")
                completion(.doNotRetryWithError(error))
            }
        }
    }
}

fileprivate extension URLRequest {
    func addingAuthorization(token: String) -> URLRequest {
        var request = self
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
}
