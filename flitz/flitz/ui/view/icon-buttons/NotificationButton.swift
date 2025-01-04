//
//  NotificationsButton.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/31/24.
//

import SwiftUI

struct NotificationButton: View {
    var badged: Bool = false
    
    var action: () -> Void = {}
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Image("Notifications")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
                if badged {
                    Circle()
                        .fill(.red)
                        .frame(width: 12, height: 12)
                        .offset(x: 8, y: -8)
                }
            }
        }
    }
}

#Preview {
    Text("NotificationButton")
    HStack {
        NotificationButton(badged: false)
        NotificationButton(badged: true)
    }
    
}
