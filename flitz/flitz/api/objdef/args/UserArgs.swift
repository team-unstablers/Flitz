//
//  User.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/10/25.
//

struct PatchSelfArgs: Codable {
    let display_name: String
    let title: String
    let bio: String
    
    let hashtags: [String]
}

struct UserPasswdArgs: Codable {
    let old_password: String
    let new_password: String
}
