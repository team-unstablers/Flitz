//
//  ImageCacheStorage.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/23/25.
//

import Foundation
import CryptoKit

import GRDB

import Alamofire
import AlamofireImage

// 동시 다운로드 관리를 위한 actor
fileprivate actor DownloadManager {
    private var activeDownloads: [String: Task<CachedImage?, Never>] = [:]
    
    func getExistingTask(for key: String) -> Task<CachedImage?, Never>? {
        return activeDownloads[key]
    }
    
    func setTask(_ task: Task<CachedImage?, Never>, for key: String) {
        activeDownloads[key] = task
    }
    
    func removeTask(for key: String) {
        activeDownloads.removeValue(forKey: key)
    }
}

final class ImageCacheStorage {
    static var cacheDirectory: URL {
        /// 반드시 성공하길 빈다
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private static var _shared: ImageCacheStorage?
    static var shared: ImageCacheStorage {
        if let instance = _shared {
            return instance
        }
        
        do {
            let instance = try ImageCacheStorage()
            _shared = instance
            return instance
        } catch {
            print("Failed to initialize ImageCacheStorage: \(error)")
            
            // 삭제를 시도해본다
            let path = Self.cacheDirectory.appendingPathComponent("image_cache.sqlite").path
            try? FileManager.default.removeItem(atPath: path)
            
            return Self.shared
        }
    }
    
    let dbQueue: DatabaseQueue
    var migrator = DatabaseMigrator()
    
    // 동시 다운로드 관리를 위한 actor
    private let downloadManager = DownloadManager()
    
    let session: Session = {
        let configuration = URLSessionConfiguration.default
        configuration.httpMaximumConnectionsPerHost = 10
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        
        return Session(configuration: configuration)
    }()

    init(_ dbName: String = "image_cache.sqlite") throws {
        let path = Self.cacheDirectory.appendingPathComponent(dbName).path
        self.dbQueue = try DatabaseQueue(path: path)
        
        self.registerMigrations()
        try migrator.migrate(self.dbQueue)
    }
    
    func resolve(by identifier: String) -> CachedImage? {
        return try? dbQueue.read { db in
            try CachedImage.fetchOne(db, id: identifier)
        }
    }
    
    func resolve(by identifier: String, origin url: URL) async -> CachedImage? {
        // DB에서 먼저 확인 (읽기는 동시 가능)
        do {
            let prevEntry: CachedImage? = try await dbQueue.read { db in
                if let cacheEntry = try CachedImage.fetchOne(db, id: identifier) {
                    if cacheEntry.urlHash == url.cacheHashKey {
                        return cacheEntry
                    }
                }
                return nil
            }
            
            if let validEntry = prevEntry {
                return validEntry
            }
        } catch {
            print("Failed to read CachedImage by identifier \(identifier): \(error)")
        }
        
        // 진행 중인 다운로드 확인
        let downloadKey = "\(identifier)_\(url.cacheHashKey)"
        
        if let existingTask = await downloadManager.getExistingTask(for: downloadKey) {
            // 이미 다운로드 중이면 그 작업을 기다림
            return await existingTask.value
        }
        
        // 새 다운로드 작업 생성
        let downloadTask = Task { () -> CachedImage? in
            do {
                // URL이 바뀐 기존 캐시 삭제
                try await dbQueue.write { db in
                    if let oldEntry = try CachedImage.fetchOne(db, id: identifier) {
                        if oldEntry.urlHash != url.cacheHashKey {
                            try oldEntry.delete(db)
                        }
                    }
                }
                
                // 새로 다운로드
                let (path, size) = try await downloadImage(from: url)
                
                let cacheEntry = CachedImage(id: identifier,
                                             urlHash: url.cacheHashKey,
                                             path: path,
                                             size: size,
                                             createdAt: Date(),
                                             updatedAt: Date())
                
                try await dbQueue.write { db in
                    try cacheEntry.insert(db)
                }
                
                return cacheEntry
            } catch {
                print("Failed to download/cache image for identifier \(identifier): \(error)")
                return nil
            }
        }
        
        await downloadManager.setTask(downloadTask, for: downloadKey)
        
        // 작업 완료 후 정리
        let result = await downloadTask.value
        await downloadManager.removeTask(for: downloadKey)
        
        return result
    }
    
    private func downloadImage(from url: URL) async throws -> (String, Int) {
        let cacheDirectory = Self.cacheDirectory.appendingPathComponent("image_cache/")
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        
        let destination = cacheDirectory.appendingPathComponent(url.cacheHashKey)
        let request = session.request(url)
        
        async let response = request.serializingImage(imageScale: 1).response
        let image = try await response.result.get()
        
        guard let data = image.jpegData(compressionQuality: 0.9) else {
            throw AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)
        }
        
        try data.write(to: destination)
        
        return ("image_cache/\(url.cacheHashKey)", data.count)
    }
}

fileprivate extension URL {
    var cacheHashKey: String {
        // remove query string
        let urlString = String(self.absoluteString.split(separator: "?").first!)
        let digest = SHA256.hash(data: urlString.data(using: .utf8)!)
        
        return digest.map { String(format: "%02.2hhx", $0) }.joined()
    }
}
