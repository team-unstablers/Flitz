//
//  RootNavigation.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/4/24.
//

import SwiftUI

enum RootModalItem: Hashable {
    case cardDetail(cardId: String)
    case myCardDetail(cardId: String)
    case userProfile(userId: String)
}

enum RootNavigationItem: Hashable {
    case cardEditor(cardId: String)
    
    case conversation(conversationId: String)
    case attachment(conversationId: String, attachmentId: String)
    
    case settings
    case editProfile
    case protectionSettings
    case blockedUsers
    case passwd
    case deactivateAccount
    case deactivateCompleted
    case logoutCompleted(reason: LogoutReason)
    
    case noticeList
    case noticeDetail(noticeId: String)
    
    case ticketList
    case ticketDetail(ticketId: String)
}

struct RootNavigation: View {
    @Environment(\.userId)
    var userId: String
    
    @EnvironmentObject
    var appState: RootAppState
    
    var body: some View {
        ZStack {
            NavigationStack(path: $appState.navState) {
                RootTabView()
                    .navigationDestination(for: RootNavigationItem.self) { item in
                        switch (item) {
                        case .cardEditor(let cardId):
                            CardEditor(cardId: cardId, client: $appState.client)
                            
                        case .conversation(let conversationId):
                            // HACK
                            if userId == UserIdKey.defaultValue {
                                EmptyView()
                            } else {
                                ConversationScreen(conversationId: conversationId)
                            }
                        case .attachment(let conversationId, let attachmentId):
                            AttachmentScreen(conversationId: conversationId, attachmentId: attachmentId)
                            
                        case .settings:
                            SettingsScreen()
                        case .editProfile:
                            ProfileEditScreen()
                        case .protectionSettings:
                            ProtectionSettingsScreen()
                        case .blockedUsers:
                            ManageUserBlockScreen()
                        case .passwd:
                            PasswdScreen()
                        case .deactivateAccount:
                            ConfirmDeactivateScreen()
                        case .deactivateCompleted:
                            DeactivateCompletedScreen()
                        case .logoutCompleted(let reason):
                            LogoutCompletedScreen(reason: reason)
                            
                        case .noticeList:
                            NoticeListScreen()
                        case .noticeDetail(let noticeId):
                            NoticeDetailScreen(noticeId: noticeId)
                            
                        case .ticketList:
                            SupportTicketListScreen()
                        case .ticketDetail(let ticketId):
                            SupportTicketDetailScreen(ticketId: ticketId)
                            
                        default:
                            EmptyView()
                        }
                    }
            }
            

            if let modalItem = appState.currentModal {
                switch modalItem {
                case .cardDetail(let cardId):
                    CardDetailModal(cardId: cardId) {
                        appState.currentModal = nil
                    }
                case .myCardDetail(let cardId):
                    MyCardDetailModal(cardId: cardId) {
                        appState.currentModal = nil
                    }
                case .userProfile(let userId):
                    UserProfileModal(userId: userId) {
                        appState.currentModal = nil
                    }
                }
            }
           
            if let assertionFailureReason = appState.assertionFailureReason {
                AssertionFailureDialog(reason: assertionFailureReason)
            }
        }
    }
}
