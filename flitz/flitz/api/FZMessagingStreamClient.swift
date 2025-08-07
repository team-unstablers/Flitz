//
//  FZMessagingStreamClient.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/1/25.
//

import Foundation
import Combine

/// WebSocket을 통한 실시간 메시징 클라이언트
class FZMessagingStreamClient: NSObject {
    
    // MARK: - Event Types
    
    /// WebSocket으로부터 받는 이벤트 타입
    enum StreamEvent {
        case connected
        case disconnected(Error?)
        case message(DirectMessage)
        case readEvent(userId: String, readAt: Date)
        case error(Error)
    }
    
    /// WebSocket 연결 상태
    enum ConnectionState {
        case disconnected
        case connecting
        case connected
        case reconnecting
    }
    
    // MARK: - Properties
    
    private let context: FZAPIContext
    private let conversationId: String
    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession?
    
    /// 이벤트 스트림을 구독할 수 있는 Publisher
    private let eventSubject = PassthroughSubject<StreamEvent, Never>()
    var eventPublisher: AnyPublisher<StreamEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }
    
    /// 현재 연결 상태
    @Published private(set) var connectionState: ConnectionState = .disconnected
    
    private var pingTimer: Timer?
    private var reconnectTimer: Timer?
    private var reconnectAttempts = 0
    private let maxReconnectAttempts = 5
    private let reconnectDelay: TimeInterval = 2.0
    
    // MARK: - Initialization
    
    init(context: FZAPIContext, conversationId: String) {
        self.context = context
        self.conversationId = conversationId
        super.init()
    }
    
    deinit {
        disconnect()
    }
    
    // MARK: - Connection Management
    
    /// WebSocket 연결 시작
    func connect() {
        guard connectionState == .disconnected else { return }
        guard let token = context.token else {
            eventSubject.send(.error(FZMessagingStreamError.missingToken))
            return
        }
        
        connectionState = .connecting
        
        // WebSocket URL 생성
        guard let url = buildWebSocketURL(token: token) else {
            eventSubject.send(.error(FZMessagingStreamError.invalidURL))
            connectionState = .disconnected
            return
        }
        
        // URLSession 설정
        let configuration = URLSessionConfiguration.default
        urlSession = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        // WebSocket 태스크 생성
        webSocketTask = urlSession?.webSocketTask(with: url)
        webSocketTask?.resume()
        
        // 메시지 수신 시작
        receiveMessage()
    }
    
    /// WebSocket 연결 해제
    func disconnect() {
        pingTimer?.invalidate()
        pingTimer = nil
        
        reconnectTimer?.invalidate()
        reconnectTimer = nil
        
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        
        urlSession?.invalidateAndCancel()
        urlSession = nil
        
        connectionState = .disconnected
        reconnectAttempts = 0
    }
    
    /// 읽음 확인 전송
    func sendReadReceipt() {
        guard connectionState == .connected else { return }
        
        let message: [String: Any] = [
            "type": "read_receipt"
        ]
        
        guard let data = try? JSONSerialization.data(withJSONObject: message) else { return }
        let string = String(data: data, encoding: .utf8) ?? ""
        
        webSocketTask?.send(.string(string)) { [weak self] error in
            if let error = error {
                self?.eventSubject.send(.error(error))
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func buildWebSocketURL(token: String) -> URL? {
        // HTTP를 WS로, HTTPS를 WSS로 변환
        let baseURL = context.host.rawValue
            .replacingOccurrences(of: "https://", with: "wss://")
            .replacingOccurrences(of: "http://", with: "ws://")
        
        // WebSocket 엔드포인트 구성
        let wsPath = "/ws/direct-messages/\(conversationId)/"
        
        // 토큰을 쿼리 파라미터로 추가
        var components = URLComponents(string: baseURL + wsPath)
        components?.queryItems = [URLQueryItem(name: "token", value: token)]
        
        return components?.url
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let message):
                self.handleMessage(message)
                // 다음 메시지 수신 대기
                self.receiveMessage()
                
            case .failure(let error):
                self.handleError(error)
            }
        }
    }
    
    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .string(let text):
            guard let data = text.data(using: .utf8) else { return }
            parseAndHandleEvent(data: data)
            
        case .data(let data):
            parseAndHandleEvent(data: data)
            
        @unknown default:
            break
        }
    }
    
    private func parseAndHandleEvent(data: Data) {
        do {
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let type = json["type"] as? String else {
                return
            }
            
            switch type {
            case "message":
                guard let messageData = json["message"] as? [String: Any],
                      let messageJSON = try? JSONSerialization.data(withJSONObject: messageData) else {
                    return
                }
                
                let decoder = JSONDecoder()
                let message = try decoder.decode(DirectMessage.self, from: messageJSON)
                eventSubject.send(.message(message))
                
            case "read_event":
                guard let userId = json["user_id"] as? String,
                      let readAtString = json["read_at"] as? String,
                      let readAt = ISO8601DateFormatter().date(from: readAtString) else {
                    return
                }
                
                eventSubject.send(.readEvent(userId: userId, readAt: readAt))
                
            default:
                break
            }
        } catch {
            eventSubject.send(.error(error))
        }
    }
    
    private func handleError(_ error: Error) {
        eventSubject.send(.error(error))
        
        // 연결이 끊어진 경우 재연결 시도
        if connectionState == .connected {
            connectionState = .disconnected
            eventSubject.send(.disconnected(error))
            attemptReconnect()
        }
    }
    
    // MARK: - Reconnection Logic
    
    private func attemptReconnect() {
        guard reconnectAttempts < maxReconnectAttempts else {
            eventSubject.send(.error(FZMessagingStreamError.maxReconnectAttemptsReached))
            return
        }
        
        reconnectAttempts += 1
        connectionState = .reconnecting
        
        reconnectTimer = Timer.scheduledTimer(withTimeInterval: reconnectDelay * Double(reconnectAttempts), repeats: false) { [weak self] _ in
            self?.connect()
        }
    }
    
    // MARK: - Ping/Pong
    
    private func startPingTimer() {
        pingTimer?.invalidate()
        pingTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.sendPing()
        }
    }
    
    private func sendPing() {
        webSocketTask?.sendPing { [weak self] error in
            if let error = error {
                self?.handleError(error)
            }
        }
    }
}

// MARK: - URLSessionWebSocketDelegate

extension FZMessagingStreamClient: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        connectionState = .connected
        reconnectAttempts = 0
        eventSubject.send(.connected)
        startPingTimer()
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        connectionState = .disconnected
        eventSubject.send(.disconnected(nil))
        
        // 정상적인 종료가 아닌 경우 재연결 시도
        if closeCode != .goingAway && closeCode != .normalClosure {
            attemptReconnect()
        }
    }
}

// MARK: - Errors

enum FZMessagingStreamError: LocalizedError {
    case missingToken
    case invalidURL
    case maxReconnectAttemptsReached
    
    var errorDescription: String? {
        switch self {
        case .missingToken:
            return "인증 토큰이 없습니다."
        case .invalidURL:
            return "WebSocket URL을 생성할 수 없습니다."
        case .maxReconnectAttemptsReached:
            return "최대 재연결 시도 횟수를 초과했습니다."
        }
    }
}