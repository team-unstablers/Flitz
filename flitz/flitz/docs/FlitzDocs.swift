//
//  FlitzDocs.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/18/25.
//

import Foundation

struct FlitzDocURL: RawRepresentable, Codable, Hashable {
    static let baseURL = "https://docs.flitz.cards"
    let rawValue: String
    
    init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    var url: URL {
        URL(string: Self.baseURL + rawValue)!
    }
}

struct FlitzDocs {
}
