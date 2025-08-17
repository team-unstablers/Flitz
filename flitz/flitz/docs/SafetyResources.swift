//
//  SafetyResources.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/10/25.
//

import Foundation

struct SafetyResource {
    
    struct ImportantNote: Hashable {
        let title: String
        let subtitle: String?
        let message: String
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(title)
            hasher.combine(message)
        }
    }
    
    let name: String
    let description: String
    
    let url: URL
    
    let importantNote: ImportantNote?
    
    init(name: String, description: String, url: URL, importantNote: ImportantNote? = nil) {
        self.name = name
        self.description = description
        
        self.url = url
        
        self.importantNote = importantNote
    }
}

extension SafetyResource: Identifiable, Hashable {
    var id: String {
        url.absoluteString
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct SafetyResources {
    
}
