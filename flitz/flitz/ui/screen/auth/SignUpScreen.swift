//
//  SignUpScreen.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/7/24.
//

import SwiftUI

struct SignUpScreen: View {
    typealias AuthHandler = (FZAPIContext) -> Void
    
#if DEBUG
    @State
    private var host: FZAPIServerHost = .default
#endif
    
    @State
    private var username = ""
    
    @State
    private var password = ""
    
    var authHandler: AuthHandler
    
    var body: some View {
        VStack {
#if DEBUG
            ServerSelector(host: $host)
#endif
            
            TextField("username", text: $username)
                .autocorrectionDisabled(true)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            
            SecureField("password", text: $password)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            
            Button("signin") {
                self.performSignIn()
            }
        }
        .padding()
    }
    
    func performSignIn() {
        var context = FZAPIContext()
#if DEBUG
        context.host = host
#endif
        
        let client = FZAPIClient(context: context)
        let credentials = FZCredentials(username: self.username,
                                        password: self.password,
                                        device_info: "FlitzCardEditorTest.app")
        
        Task {
            do {
                let token = try await client.authorize(with: credentials)
                var newContext = context
                newContext.token = token.token
                
                DispatchQueue.main.async {
                    self.authHandler(newContext)
                }
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    SignUpScreen { _ in
    }
}
