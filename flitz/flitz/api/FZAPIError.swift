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
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}
