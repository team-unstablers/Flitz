//
//  FZAPIClient.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/4/24.
//

import Foundation
import UIKit

import Alamofire

class FZAPIClient {
    private let logger = createFZOSLogger("FZAPIClient")
    static var userAgent: String {
        let appVersion = Flitz.version
        let buildNumber = Flitz.build
        let codename = Flitz.codename
        
        return "Flitz/\(appVersion) (\(codename); build \(buildNumber))"
    }
    
    let session: Session = {
        let configuration = URLSessionConfiguration.default
        configuration.httpMaximumConnectionsPerHost = 10
        configuration.timeoutIntervalForRequest = 10
        configuration.timeoutIntervalForResource = 10
        configuration.httpShouldSetCookies = false
        configuration.waitsForConnectivity = true
        configuration.multipathServiceType = .handover
        
        // User-Agent 설정
           
        if var existingHeaders = configuration.httpAdditionalHeaders {
            if let existingUserAgent = existingHeaders["User-Agent"] as? String {
                existingHeaders["User-Agent"] = "\(existingUserAgent) \(FZAPIClient.userAgent)"
            } else {
                existingHeaders["User-Agent"] = FZAPIClient.userAgent
            }
            configuration.httpAdditionalHeaders = existingHeaders
        } else {
            configuration.httpAdditionalHeaders = ["User-Agent": FZAPIClient.userAgent]
        }
        
        return Session(configuration: configuration)
    }()
    
    var context: FZAPIContext
    var interceptor: FZTokenRefreshInterceptor!
    
    /// KILL SWITCH - true로 설정되면 모든 네트워크 요청을 차단합니다.
    /// MITM 공격이 감지되었을 때 활성화 하십시오.
    private var killSwitch: Bool = false

    init(context: FZAPIContext) {
        self.context = context
        self.interceptor = FZTokenRefreshInterceptor(self)
    }
    
    private func handleRequestError(_ error: AFError?, response: DataRequest) throws {
        guard let error = error else {
            throw FZAPIError.invalidResponse
        }
        
        switch error {
        case .responseValidationFailed(let reason):
            switch reason {
            case .unacceptableStatusCode(let code):
                if code == 400 {
                    let jsonDecoder = JSONDecoder()
                    if let data = response.data,
                       let simpleResponse = try? jsonDecoder.decode(SimpleResponse.self, from: data) {
                        throw FZAPIError.badRequest(response: simpleResponse)
                    }
                    throw FZAPIError.badRequest(response: nil)
                }
                break
            default:
                break
            }
            break
        default:
            break
        }
        
        let underlyingError = error.underlyingError
        
        if let urlError = underlyingError as? URLError {
            if urlError.code == .secureConnectionFailed {
                DispatchQueue.main.async {
                    if UIApplication.shared.applicationState == .active {
                        self.killSwitch = true
                        RootAppState.shared.assertionFailureReason = .sslFailure
                    }
                }
                
                throw FZAPIError.sslFailure
            }
        }
        
        throw error
    }
    
    func request<Parameters: Encodable & Sendable, Response>(
        to url: URL,
        expects type: Response.Type,
        method: HTTPMethod = .get,
        parameters: Parameters = Dictionary<String, String>(),
        requiresAuth: Bool = true
    ) async throws -> Response where Response: Decodable & Sendable {
        if killSwitch {
            logger.fatal("KILL SWITCH ACTIVATED - Blocking all network requests")
            throw FZAPIError.killSwitchActivated
        }
        
        let response = session.request(url,
                                       method: method,
                                       parameters: parameters,
                                       encoder: method == .get ? URLEncodedFormParameterEncoder.default : JSONParameterEncoder.default,
                                       headers: nil,
                                       interceptor: (requiresAuth) ? interceptor : nil)
            .validate()
        
        // Ditch 타입일 경우 빈 응답 처리
        if type == Ditch.self {
            let dataResponse = await response.serializingData().response
            
            if dataResponse.error != nil {
                try handleRequestError(dataResponse.error, response: response)
            }
            
            // 빈 응답이나 빈 JSON 객체 모두 Ditch로 처리
            return Ditch() as! Response
        }
        
        // 일반적인 Decodable 타입 처리
        let serializingResponse = await response.serializingDecodable(type).response
        
        guard let value = serializingResponse.value else {
            try handleRequestError(serializingResponse.error, response: response)
            
            throw FZAPIError.invalidResponse
        }
        
        return value
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
        guard let previous = pagination.previous,
              let url = URL(string: previous) else {
            return nil
        }
        
        return try await self.request(to: url,
                                      expects: Paginated<T>.self)
    }
}
