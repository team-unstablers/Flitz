//
//  FZTokenRefreshInterceptor.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/24/25.
//

import Foundation
import Alamofire

final class FZTokenRefreshInterceptor: RequestInterceptor {
    weak var client: FZAPIClient? = nil
    
    private let refreshQueue = DispatchQueue(label: "pl.unstabler.flitz.token-refresh")
    private var isRefreshing = false
    private var requestsToRetry: [(RetryResult) -> Void] = []
    
    func adapt(_ urlRequest: URLRequest,
               for session: Session,
               completion: @escaping (Result<URLRequest, any Error>) -> Void) {
        
        guard let client = client else {
            completion(.failure(FZAPIError.assertionFailure(message: "FZAPIClient is nil")))
            return
        }
        
        if client.context.expired {
            refreshQueue.async { [weak self] in
                guard let self = self else {
                    completion(.failure(FZAPIError.assertionFailure(message: "Self is nil")))
                    return
                }
                
                if self.isRefreshing {
                    self.requestsToRetry.append { result in
                        switch result {
                        case .retry:
                            var urlRequest = urlRequest
                            if let token = self.client?.context.token {
                                urlRequest.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
                            }
                            completion(.success(urlRequest))
                        case .doNotRetry:
                            completion(.failure(FZAPIError.unauthorized))
                        case .doNotRetryWithError(let error):
                            completion(.failure(error))
                        case .retryWithDelay(_):
                            completion(.failure(FZAPIError.unauthorized))
                        @unknown default:
                            completion(.failure(FZAPIError.unauthorized))
                        }
                    }
                    return
                }
                
                self.performTokenRefresh { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        var urlRequest = urlRequest
                        if let token = self.client?.context.token {
                            urlRequest.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
                        }
                        completion(.success(urlRequest))
                    }
                }
            }
        } else {
            completion(.success(urlRequest))
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
        
        refreshQueue.async { [weak self] in
            guard let self = self else {
                completion(.doNotRetryWithError(FZAPIError.assertionFailure(message: "Self is nil")))
                return
            }
            
            if self.isRefreshing {
                self.requestsToRetry.append(completion)
                return
            }
            
            if !client.context.expired {
                client.context = FZAPIContext.load()
                _ = client.context.valid()
            }
            
            self.performTokenRefresh { error in
                if let error = error {
                    completion(.doNotRetryWithError(error))
                } else {
                    completion(.retry)
                }
            }
        }
    }
    
    private func performTokenRefresh(completion: @escaping (Error?) -> Void) {
        guard !isRefreshing else {
            return
        }
        
        isRefreshing = true
        
        guard let refreshToken = client?.context.refreshToken else {
            isRefreshing = false
            completion(FZAPIError.noRefreshToken)
            
            for handler in requestsToRetry {
                handler(.doNotRetryWithError(FZAPIError.noRefreshToken))
            }
            requestsToRetry.removeAll()
            return
        }
        
        Task {
            do {
                let args = RefreshTokenArgs(refresh_token: refreshToken)
                guard let token = try await client?.refreshToken(args) else {
                    throw FZAPIError.tokenRefreshFailed(reason: "Failed to get token from server")
                }
                
                var context = FZAPIContext()
                context.token = token.token
                context.refreshToken = token.refresh_token
                
                guard context.valid() else {
                    throw FZAPIError.invalidToken
                }
                
                context.save()
                
                await MainActor.run {
                    self.client?.context = context
                }
                
                self.refreshQueue.async {
                    self.isRefreshing = false
                    completion(nil)
                    
                    for handler in self.requestsToRetry {
                        handler(.retry)
                    }
                    self.requestsToRetry.removeAll()
                }
            } catch {
                self.refreshQueue.async {
                    self.isRefreshing = false
                    let apiError = error as? FZAPIError ?? FZAPIError.networkError(underlying: error)
                    completion(apiError)
                    
                    for handler in self.requestsToRetry {
                        handler(.doNotRetryWithError(apiError))
                    }
                    self.requestsToRetry.removeAll()
                }
            }
        }
    }
}