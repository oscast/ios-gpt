//
//  ChatService.swift
//  chat-gpt-ios
//
//  Created by Oscar Castillo on 17/6/24.
//

import Foundation
import SwiftUI

protocol ChatServiceType {
    var networkService: RequesterType { get }
    func sendMessage(_ message: Message, includeSystemRole: Bool) async throws -> OpenAIResponse
    func streamMessage(_ message: Message, includeSystemRole: Bool, onReceive: @escaping (Result<Message, Error>) -> Void)
}

struct ChatService: ChatServiceType {
    let networkService: RequesterType
    
    static var systemMessage = Message(role: .system, content: "You are a useful assistant expert on everything and willing to help the user.")
    
    init(networkService: RequesterType = NetworkService()) {
        self.networkService = networkService
    }
    
    func sendMessage(_ message: Message, includeSystemRole: Bool = false) async throws -> OpenAIResponse {
        let messages = buildMessages(message, includeSystemRole: includeSystemRole)
        let request = buildOpenRequest(messages: messages)
        
        let endpoint = try OpenAIEndpoint(request: request)
        return try await networkService.request(endpoint: endpoint, responseModel: OpenAIResponse.self)
    }
    
    func streamMessage(_ message: Message, includeSystemRole: Bool, onReceive: @escaping (Result<Message, Error>) -> Void) {
        let messages = buildMessages(message, includeSystemRole: includeSystemRole)
        let request = buildOpenRequest(messages: messages, stream: true)
        
        guard let endpoint = try? OpenAIEndpoint(request: request) else {
            onReceive(.failure(NetworkError.invalidURL))
            return
        }
        
        networkService.streamRequest(endpoint: endpoint, onReceive: onReceive)
    }
    
    private func buildMessages(_ message: Message, includeSystemRole: Bool) -> [Message] {
        var messages: [Message] = [message]
        if includeSystemRole {
            messages.insert(ChatService.systemMessage, at: 0)
        }
        return messages
    }
    
    private func buildOpenRequest(messages: [Message], stream: Bool = false) -> OpenAIRequest {
        OpenAIRequest(
            messages: messages,
            stream: stream
        )
    }
}

