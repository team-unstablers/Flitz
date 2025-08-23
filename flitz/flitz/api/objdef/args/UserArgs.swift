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

struct UserDeactivationArgs: Codable {
    let password: String
    let feedback: String?
}

struct FlagUserReason: RawRepresentable, Codable, Equatable, Hashable {
    var rawValue: String
    
    init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.rawValue = try container.decode(String.self)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
    
    static let inappropriateProfile = Self.init(rawValue: "INAPPROPRIATE_PROFILE")
    static let impersonation = Self.init(rawValue: "IMPERSONATION")
    static let illegalContents = Self.init(rawValue: "ILLEGAL_CONTENTS")
    static let minor = Self.init(rawValue: "MINOR")
    static let other = Self.init(rawValue: "OTHER")

}

struct FlagUserArgs: Codable {
    let message: String?
    
    let reason: [FlagUserReason]
    let user_description: String?
}
