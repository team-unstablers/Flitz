//
//  FZAPIClient+Wave.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/1/25.
//

extension FZAPIClient {
    func noticeList() async throws -> Paginated<SimpleNotice> {
        return try await self.request(to: .notices,
                                      expects: Paginated<SimpleNotice>.self,
                                      method: .get)
    }
    
    func notice(id: String) async throws -> Notice {
        return try await self.request(to: .notice(id: id),
                                      expects: Notice.self,
                                      method: .get)
    }
}
