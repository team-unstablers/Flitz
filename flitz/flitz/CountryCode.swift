//
//  CountryCode.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/29/25.
//

import Foundation

enum CountryCode: String, CaseIterable, Equatable, Hashable {
    case KR = "kr"
    case OTHER = "__"
    
    var isSupported: Bool {
        switch self {
        case .KR:
            return true
        default:
            return false
        }
    }
    
    var displayName: String {
        switch self {
        case .KR:
            return NSLocalizedString("core.country.kr", comment: "대한민국")
        case .OTHER:
            return NSLocalizedString("core.country.other", comment: "그 외 국가")
        default:
            return self.rawValue.uppercased()
        }
    }
}
