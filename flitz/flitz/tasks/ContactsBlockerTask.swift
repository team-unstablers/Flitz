//
//  ContactsBlockerTask.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/15/25.
//

import Contacts

class ContactsBlockerTask {
    static var enabled: Bool {
        UserDefaults.standard.bool(forKey: "ContactsBlockerEnabled")
    }
    
    static func setEnabled(_ enabled: Bool) async {
        UserDefaults.standard.set(enabled, forKey: "ContactsBlockerEnabled")
        
        if (enabled) {
            guard await ContactsBlocker.requestPermission() else {
                #warning("TODO: 오류 메시지를 표시해야 합니다. (권한 미부여)")
                return
            }
        }
    }
    
    static func updateEnabled() async {
        let client = await RootAppState.shared.client
        guard let response = try? await client.contactTriggerEnabled() else {
            print("Failed to fetch contacts blocker status.")
            return
        }
        
        let enabled = response.is_enabled
        await setEnabled(enabled)
    }
    
    func execute() async {
        guard ContactsBlockerTask.enabled else {
            print("Contacts blocker is not enabled.")
            return
        }
        
        let blocker = ContactsBlocker()
        let contacts = blocker.getAllContacts()
        
        let phoneNumbers = contacts.compactMap { contact -> String? in
            guard let phoneNumber = contact.phoneNumbers.first?.value.stringValue else {
                return nil
            }
            return phoneNumber
        }
        
        guard !phoneNumbers.isEmpty else {
            print("No phone numbers found in contacts.")
            return
        }
        
        do {
            let client = await RootAppState.shared.client
            
            let args = ContactsTriggerBulkCreateArgs(phone_numbers: phoneNumbers)
            
            try await client.contactTriggerBulkCreate(args)
        } catch {
            print("Failed to create contacts trigger: \(error)")
        }
    }
}
