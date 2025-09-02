//
//  NoticeListScreen.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/17/25.
//

import SwiftUI

@MainActor
class SupportTicketListViewModel: ObservableObject {
    @Published
    var tickets: [SupportTicket] = []
    
    @Published
    var isLoading: Bool = false
    
    @Published
    var isLoadingMore: Bool = false
    
    private var currentPagination: Paginated<SupportTicket>? = nil
    
    // This would typically be where you fetch the notices from an API or database.
    func fetchTickets() async {
        guard !isLoading else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        let client = RootAppState.shared.client
        
        do {
            let pagination = try await client.supportTicketList()
            self.tickets = pagination.results
            self.currentPagination = pagination
        } catch {
            #warning("잘못된 오류 처리")
            print("Failed to fetch notices: \(error)")
        }
    }
    
    func loadMore() async {
        guard !isLoadingMore,
              let currentPagination = currentPagination,
              currentPagination.next != nil else { return }
        
        isLoadingMore = true
        defer { isLoadingMore = false }
        
        let client = RootAppState.shared.client
        
        do {
            if let nextPage = try await client.nextPage(currentPagination) {
                self.tickets.append(contentsOf: nextPage.results)
                self.currentPagination = nextPage
            }
        } catch {
            #warning("잘못된 오류 처리")
            print("Failed to load more notices: \(error)")
        }
    }
}

struct SupportTicketItem: View {
    let title: String
    let createdAt: Date
    
    let isResolved: Bool
    
    let action: (() -> Void)
    
    var body: some View {
        Button {
            action()
        } label: {
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title.byCharWrapping)
                            .font(.fzHeading3)
                            .foregroundStyle(Color.Brand.black0)
                            .lineLimit(1)
                        
                        Text(createdAt.localeDateString)
                            .font(.fzMain)
                            .foregroundStyle(Color.Grayscale.gray6)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Image("NavRightIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                }
                .padding(16)
                
                Divider()
                    .background(Color.Grayscale.gray2)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct SupportTicketListScreen: View {
    @EnvironmentObject
    var appState: RootAppState
    
    @StateObject
    var viewModel = SupportTicketListViewModel()
    
    @State
    var isNewTicketSheetPresented: Bool = false
    
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.tickets) { ticket in
                    NoticeListItem(title: ticket.title, createdAt: ticket.parsedCreatedAt) {
                        navigate(to: ticket.id)
                    }
                    .onAppear {
                        // Load more when last item appears
                        if ticket.id == viewModel.tickets.last?.id {
                            Task {
                                await viewModel.loadMore()
                            }
                        }
                    }
                }
                
                // Loading indicator
                if viewModel.isLoadingMore {
                    HStack {
                        Spacer()
                        ProgressView()
                            .padding()
                        Spacer()
                    }
                }
            }
        }
        .overlay(alignment: .center) {
            if viewModel.isLoading && viewModel.tickets.isEmpty {
                ProgressView()
            }
        }
        .navigationTitle("ui.support.ticket_list.title")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isNewTicketSheetPresented = true
                } label: {
                    Text("ui.support.ticket_list.new")
                        .font(.fzMain)
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchTickets()
            }
        }
        .sheet(isPresented: $isNewTicketSheetPresented) {
            NewSupportTicketSheet {
                isNewTicketSheetPresented = false
                Task {
                    await viewModel.fetchTickets()
                }
            }
        }
    }
    
    func navigate(to ticketId: String) {
        appState.navState.append(.ticketDetail(ticketId: ticketId))
    }
}

extension SupportTicket {
    var parsedCreatedAt: Date {
        return created_at.asISO8601Date!
    }
}

