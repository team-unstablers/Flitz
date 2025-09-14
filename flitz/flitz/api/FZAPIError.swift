//
//  FZAPIError.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/4/24.
//

import Foundation

enum FZAPIError: LocalizedError {
    case assertionFailure(message: String)
    case tokenRefreshFailed(reason: String)
    case noRefreshToken
    case invalidToken
    case unauthorized
    case invalidResponse
    case sessionInvalidated
    
    case badRequest(response: SimpleResponse?)
    
    case sslFailure
    case killSwitchActivated
    
    case networkError(underlying: Error)
    
    var errorDescription: String? {
        switch self {
        case .assertionFailure(let message):
            return "Assertion failed: \(message)"
        case .tokenRefreshFailed(let reason):
            return "Token refresh failed: \(reason)"
        case .noRefreshToken:
            return "No refresh token available"
        case .invalidToken:
            return "Invalid token received"
        case .unauthorized:
            return "Unauthorized access"
        case .invalidResponse:
            return "Invalid response from server"
        case .sessionInvalidated:
            return "Session has been invalidated"
        case .badRequest(let response):
            if let reason = response?.reason {
                return NSLocalizedString(reason, comment: "")
            }
            
            return "Bad request"
        case .sslFailure:
            return "SSL failure occurred"
        case .killSwitchActivated:
            return "Kill switch activated"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
    
}
