//
//  AuthArgs.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/14/25.
//

import Foundation

struct RefreshTokenArgs: Codable {
    var refresh_token: String
}

struct ResetPasswordRequestArgs: Codable {
    let username: String
    let country_code: String
    let phone_number: String
}

struct ResetPasswordConfirmArgs: Codable {
    let session_id: String
    let verification_code: String
    
    let new_password: String
}
