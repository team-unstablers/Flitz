//
//  FZAPIEndpoint.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/4/24.
//

import Foundation

struct FZAPIEndpoint: RawRepresentable {
    var rawValue: String
    
    init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    static let token = FZAPIEndpoint(rawValue: "/auth/token")
    static let refreshToken = FZAPIEndpoint(rawValue: "/auth/token/refresh")
    
    static let resetPasswordRequest = FZAPIEndpoint(rawValue: "/users/reset-password/")
    static let resetPasswordConfirm = FZAPIEndpoint(rawValue: "/users/reset-password/confirm/")

    // MARK: wavespot
    static let wavespotAuthorize = FZAPIEndpoint(rawValue: "/wavespot/authorize/")
    static let wavespotCards = FZAPIEndpoint(rawValue: "/wavespot/cards/")
    static let wavespotCardDetail = FZAPIEndpoint(rawValue: "/wavespot/cards/{card_id}/")

    // MARK: utility functions
    func urlString(for server: String) -> String {
        return "\(server)\(self.rawValue)"
    }
    
    func url(for server: String) -> URL {
        return URL(string: self.urlString(for: server))!
    }
}
