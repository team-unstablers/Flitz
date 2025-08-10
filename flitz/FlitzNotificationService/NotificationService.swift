//
//  NotificationService.swift
//  FlitzNotificationService
//
//  Created by Gyuhwan Park on 8/10/25.
//

import UserNotifications
import Intents

enum FZNotificationServiceError: LocalizedError {
    case invalidNotificationContent
    case unsupportedNotificationType(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidNotificationContent:
            return "The notification content is invalid."
        case .unsupportedNotificationType(let type):
            return "Unsupported notification type: \(type)"
        }
    }
}


class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        guard let bestAttemptContent = request.content.mutableCopy() as? UNMutableNotificationContent else {
            contentHandler(request.content)
            return
        }
        
        let userInfo = bestAttemptContent.userInfo
        let type = userInfo["type"] as? String ?? "unknown"
        
        Task {
            do {
                switch type {
                case "message":
                    try await handle(messageNotification: bestAttemptContent, contentHandler: contentHandler)
                    break
                default:
                    throw FZNotificationServiceError.unsupportedNotificationType(type)
                }
            } catch {
                // Handle any errors that occur during notification handling
                print("Error handling notification: \(error)")
                contentHandler(bestAttemptContent)
                return
            }
        }
        
        
        // Modify the notification content here...
        // bestAttemptContent.title = "\(bestAttemptContent.title) [modified]"
    }
    
    func handle(messageNotification content: UNMutableNotificationContent, contentHandler: @escaping (UNNotificationContent) -> Void) async throws {
        guard let userId = content.userInfo["user_id"] as? String,
              let conversationId = content.userInfo["conversation_id"] as? String,
              let displayName = content.userInfo["user_display_name"] as? String,
              let messageContent = content.userInfo["message_content"] as? String
        else {
            throw FZNotificationServiceError.invalidNotificationContent
        }
        
        var inImage: INImage? = nil
        
        
        if let profileImageUrlString = content.userInfo["user_profile_image_url"] as? String,
           let profileImageUrl = URL(string: profileImageUrlString) {
            await ImageCacheManager.shared.prefetchImagesAsync(urls: [profileImageUrl])
            
            if let cachedImage = ImageCacheManager.shared.imageCache.image(for: URLRequest(url: profileImageUrl), withIdentifier: nil),
               let imageData = cachedImage.jpegData(compressionQuality: 0.85) {
                // FIXME: 이거 다른 방식으로 구현해야 할듯; 매번 이미지 컴프레싱 하고 있으면 배터리가 죽어나요 ㅠ_ㅠ
                
                inImage = INImage(imageData: imageData)
            }
        }
       
        let handle = INPersonHandle(value: userId, type: .unknown)
        let sender = INPerson(personHandle: handle,
                              nameComponents: nil,
                              displayName: displayName,
                              image: inImage,
                              contactIdentifier: nil,
                              customIdentifier: nil,
                              isMe: false)
        
        let meHandle = INPersonHandle(value: "__FLITZ_ME__", type: .unknown)
        let me = INPerson(personHandle: meHandle,
                          nameComponents: nil,
                          displayName: nil,
                          image: nil,
                          contactIdentifier: nil,
                          customIdentifier: "__FLITZ_ME__",
                          isMe: true)
        
        
        let intent = INSendMessageIntent(recipients: [me],
                                         outgoingMessageType: .outgoingMessageText,
                                         content: messageContent,
                                         speakableGroupName: nil,
                                         conversationIdentifier: conversationId,
                                         serviceName: nil,
                                         sender: sender,
                                         attachments: nil)
        
        let interaction = INInteraction(intent: intent, response: nil)
        interaction.direction = .incoming
        try? await interaction.donate()
        
        guard let updated = try content.updating(from: intent) as? UNMutableNotificationContent else {
            throw FZNotificationServiceError.invalidNotificationContent
        }
        
        contentHandler(updated)
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
