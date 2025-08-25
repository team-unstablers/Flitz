//
//  CFTurnstile.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/25/25.
//

import SwiftUI
import WebKit
import Combine
import SafariServices

struct CFTurnstileWebView: UIViewRepresentable {
    @Binding
    var html: String
    
    var publisher = PassthroughSubject<[String: Any], Never>()

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        return webView
    }
    
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if context.coordinator.htmlContent != html {
            webView.stopLoading()
            
            webView.configuration.userContentController.removeScriptMessageHandler(forName: "eventHandler")
            webView.configuration.userContentController.add(context.coordinator, name: "eventHandler")

            webView.loadHTMLString(html, baseURL: URL(string: "https://challenges.app.flitz.cards")!)
            context.coordinator.htmlContent = html
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(publisher: self.publisher)
    }
    
    class Coordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate {
        var htmlContent: String = ""
        
        var publisher: PassthroughSubject<[String: Any], Never>
        
        init(publisher: PassthroughSubject<[String: Any], Never>) {
            self.publisher = publisher
        }
        
        func userContentController(_ userContentController: WKUserContentController,
                                   didReceive message: WKScriptMessage) {
            if message.name == "eventHandler" {
                guard let json = message.body as? String else {
                    print("Invalid message body")
                    return
                }
                
                // decode json to dictionary
                let data = Data(json.utf8)
                guard let body = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    print("Failed to decode JSON")
                    return
                }
                
                publisher.send(body)
                
            }
        }
        
        // WKNavigationDelegate - 외부 링크 처리
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url {
                // Cloudflare 도메인이 아닌 외부 링크는 Safari로 열기
                if navigationAction.targetFrame == nil || 
                   (url.scheme == "https" && !url.host!.contains("cloudflare.com") && !url.host!.contains("challenges.app.flitz.cards")) {
                    UIApplication.shared.open(url)
                    decisionHandler(.cancel)
                    return
                }
            }
            decisionHandler(.allow)
        }
        
        // WKUIDelegate - 새 창 처리
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if let url = navigationAction.request.url {
                UIApplication.shared.open(url)
            }
            return nil
        }
    }
}


struct CFTurnstile: View {
    static let siteKey = "0x4AAAAAABunYPdYJnFzwHAZ"
    
    var action: String
    var nonce: UUID
    
    var tokenHandler: (String) -> Void
    
    @State
    var widgetSize: CGSize = CGSize(width: 300, height: 70)
    
    
    @State
    var html: String = ""
    
    func generateHTML() -> String {
"""
<!-- \(nonce.uuidString) -->
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
<script src="https://challenges.cloudflare.com/turnstile/v0/api.js?onload=_turnstileCb" async defer></script>

<style>
html, body {
    margin: 0;
    padding: 0;
    width: 100%; height: 100%;
    overflow: hidden;
    display: flex;
    justify-content: center;
    align-items: center;
}
</style>

<script>
function sendEvent(value) {
    webkit.messageHandlers.eventHandler.postMessage(value);
}
</script>
</head>
<body>
<div id="FZCFTurnstileWidget"></div>
<script>
function _turnstileCb() {
    turnstile.render('#FZCFTurnstileWidget', {
        sitekey: '\(Self.siteKey)',
        size: 'normal',
        theme: 'light',
        action: '\(action)',
        callback: function(token) {
            sendEvent(JSON.stringify({ type: 'success', token }));
        },
        'error-callback': function() {
            // sendEvent('error');
        },
        'expired-callback': function() {
            // sendEvent('expired');
        }
    });

    setTimeout(() => {
        const widget = document.getElementById('FZCFTurnstileWidget');
        const elementWidth = widget.offsetWidth;
        const elementHeight = widget.offsetHeight;

        sendEvent(JSON.stringify({ type: 'widget-resize', width: elementWidth, height: elementHeight }));
    }, 1000);
}
</script>
</body>
</html>
"""
    }
    
    var body: some View {
        let webView = CFTurnstileWebView(html: $html)
        
        webView
            .frame(width: widgetSize.width, height: widgetSize.height)
            .background(.red)
            .onReceive(webView.publisher) { event in
                handleEvent(event)
            }
            .onAppear {
                self.html = generateHTML()
            }
            .onChange(of: nonce) { _, newValue in
                self.html = generateHTML()
            }
    }
    
    func handleEvent(_ event: [String: Any]) {
        guard let type = event["type"] as? String else {
            print("Invalid event")
            return
        }
        
        switch type {
        case "widget-resize":
            if let width = event["width"] as? CGFloat,
               let height = event["height"] as? CGFloat {
                print("Widget resized: \(width)x\(height)")
                // Handle resizing logic here if needed
                self.widgetSize = CGSize(width: width, height: height)
            }
        case "success":
            if let token = event["token"] as? String {
                tokenHandler(token)
            }
        default:
            break
        }
        
    }
}


#Preview {
    @Previewable
    @State
    var nonce = UUID()
    
    VStack {
        CFTurnstile(action: "login", nonce: nonce) { token in
            print("token: \(token)")
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.blue)
}
