//
//  CachedImage.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/23/25.
//

import Foundation
import GRDB

struct CachedImage: Codable, Identifiable, FetchableRecord, PersistableRecord, Equatable, Hashable {
    static var databaseTableName: String = "cached_image"
    // XXX: cache identifier를 PK로 둬도 문제 없는가?
    var id: String
    var urlHash: String
    
    var path: String
    var size: Int
    
    var createdAt: Date
    var updatedAt: Date
    
    enum Columns {
        static let urlHash = Column(CodingKeys.urlHash)
        
        static let path = Column(CodingKeys.path)
        static let size = Column(CodingKeys.size)
        
        static let createdAt = Column(CodingKeys.createdAt)
        static let updatedAt = Column(CodingKeys.updatedAt)
    }
    
    var url: URL {
        return ImageCacheStorage.cacheDirectory.appendingPathComponent(path)
    }
}
