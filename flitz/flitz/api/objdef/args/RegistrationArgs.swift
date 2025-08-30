//
//  AuthArgs.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/14/25.
//

import Foundation

struct StartRegistrationSessionArgs: Codable {
    let country_code: String
    let agree_marketing_notifications: Bool
    
    let device_info: String
    let apns_token: String?
    
    let turnstile_token: String
}

struct RegistrationStartPhoneVerificationArgs: Codable {
    let phone_number: String?
}

struct RegistrationCompletePhoneVerificationArgs: Codable {
    // 해외 휴대폰 인증 전용 필드
    let verification_code: String?
    
    // 대한민국 휴대폰 인증 전용 필드
    let encrypted_payload: String?
    let payload_hmac: String?
}

struct UserRegistrationArgs: Codable {
    var username: String
    var password: String
    
    var display_name: String
    
    var title: String
    var bio: String
    var hashtags: [String]
}

struct UsernameAvailabilityArgs: Codable {
    var username: String
}
