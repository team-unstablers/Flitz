//
//  User.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 11/29/24.
//

import Foundation

struct FZCredentials: Codable {
    var username: String
    var password: String
    
    var device_info: String
    var apns_token: String?
}

struct FZUserToken: Codable {
    var token: String
}

struct FZUser: Codable, Identifiable {
    var id: String
    var username: String
    var display_name: String
    
    var profile_image_url: String?
}
