//
//  ImageCacheStorage+migrations.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/23/25.
//

import Foundation
import GRDB

extension ImageCacheStorage {
    func registerMigrations() {
        migrator.registerMigration("v1") { db in
            try db.create(table: "cached_image") { t in
                t.primaryKey("id", .text)
                t.column("urlHash", .text).indexed()
                t.column("path", .text)
                t.column("size", .integer)
                t.column("createdAt", .datetime).notNull().defaults(sql: "CURRENT_TIMESTAMP")
                t.column("updatedAt", .datetime).notNull().defaults(sql: "CURRENT_TIMESTAMP")
            }
        }
    }
}
