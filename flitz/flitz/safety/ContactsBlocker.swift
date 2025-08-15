//
//  ContactsBlockerTask.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/15/25.
//

import Contacts

class ContactsBlocker {
    static func requestPermission() async -> Bool {
        let store = CNContactStore()
        
        do {
            let authorized = try await store.requestAccess(for: .contacts)
            return authorized
        } catch {
            print("Failed to request contacts permission: \(error)")
            return false
        }
    }
    
    static var isAuthorized: Bool {
        return CNContactStore.authorizationStatus(for: .contacts) == .authorized
    }
    
    func getAllContacts() -> [CNContact] {
        guard Self.isAuthorized else {
            print("Contacts permission not authorized")
            return []
        }
        
        let store = CNContactStore()
        let keysToFetch = [
            CNContactGivenNameKey,
            CNContactFamilyNameKey,
            CNContactPhoneNumbersKey,
        ] as [CNKeyDescriptor]
        
        let request = CNContactFetchRequest(keysToFetch: keysToFetch)
        var contacts: [CNContact] = []
        
        do {
            try store.enumerateContacts(with: request) { contact, _ in
                contacts.append(contact)
            }
        } catch {
            print("Failed to fetch contacts: \(error)")
        }
        
        return contacts
    }
}
