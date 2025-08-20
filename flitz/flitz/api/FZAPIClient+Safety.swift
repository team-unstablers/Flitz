//
//  FZAPIClient+Wave.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/1/25.
//

extension FZAPIClient {
    func blocksList() async throws -> Paginated<FZUserBlock> {
        return try await self.request(to: .blocks, expects: Paginated<FZUserBlock>.self)
    }
    
    func contactTriggersList() async throws -> Paginated<FZContactsTrigger> {
        return try await self.request(to: .contactTriggers, expects: Paginated<FZContactsTrigger>.self)
    }
    
    func contactTriggerEnabled() async throws -> FZContactsTriggerEnabled {
        return try await self.request(to: .contactTriggersEnabled, expects: FZContactsTriggerEnabled.self)
    }
    
    func setContactTriggerEnabled(_ args: FZContactsTriggerEnabled) async throws -> FZContactsTriggerEnabled {
        return try await self.request(to: .contactTriggersEnabled,
                                      expects: FZContactsTriggerEnabled.self,
                                      method: .patch,
                                      parameters: args)
    }

    
    func contactTriggerBulkCreate(_ args: ContactsTriggerBulkCreateArgs) async throws {
        _ = try await self.request(to: .contactTriggersBulkCreate,
                                      expects: Ditch.self,
                                      method: .post,
                                      parameters: args)
    }

    
    func contactTriggerDeleteAll() async throws {
        _ = try await self.request(to: .contactTriggersAll,
                                      expects: Ditch.self,
                                      method: .delete)
    }
}
