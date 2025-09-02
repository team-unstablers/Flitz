//
//  FZAPIClient+Wave.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/1/25.
//

extension FZAPIClient {
    func supportTicketList() async throws -> Paginated<SupportTicket> {
        return try await self.request(to: .supportTickets,
                                      expects: Paginated<SupportTicket>.self,
                                      method: .get)
    }
    
    func supportTicket(id: String) async throws -> SupportTicket {
        return try await self.request(to: .supportTicket(id: id),
                                      expects: SupportTicket.self,
                                      method: .get)
    }
    
    func postSupportTicket(_ args: SupportTicketArgs) async throws -> SupportTicket {
        return try await self.request(to: .supportTickets,
                                      expects: SupportTicket.self,
                                      method: .post,
                                      parameters: args)
    }
    
    func supportTicketResponses(of ticketId: String) async throws -> [SupportTicketResponse] {
        return try await self.request(to: .supportTicketResponses(ticketId: ticketId),
                                      expects: Array<SupportTicketResponse>.self,
                                      method: .get)
    }
    
    func postSupportTicketResponse(of ticketId: String, _ args: SupportTicketResponseArgs) async throws -> SupportTicketResponse {
        return try await self.request(to: .supportTicketResponses(ticketId: ticketId),
                                      expects: SupportTicketResponse.self,
                                      method: .post,
                                      parameters: args)
    }
}
