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
    func sendMessage(_ message: Message, includeSystemRole: Bool, stream: Bool) async throws -> OpenAIResponse
}

struct ChatService: ChatServiceType {
    let networkService: RequesterType
    
    static var systemMessage = Message(role: .system, content: "You are useful assitant expert on everything")
    
    init(networkService: RequesterType = NetworkService()) {
        self.networkService = networkService
    }
    
    func sendMessage(_ message: Message, includeSystemRole: Bool = true, stream: Bool = false) async throws -> OpenAIResponse {
        var messages: [Message] = []
        
        messages.append(Message(role: .user, content: message.content))
        
        var messagesToSend: [Message] = []
        
        if includeSystemRole {
            messages.append(ChatService.systemMessage)
            messagesToSend = messages.filter { $0.role != .system } + [ChatService.systemMessage]
        } else {
            messagesToSend = messages
        }
        
        let request = OpenAIRequest(
            model: "gpt-3.5-turbo",
            messages: messagesToSend
        )
        
        let endpoint = try OpenAIEndpoint(request: request)
        return try await networkService.request(endpoint: endpoint, responseModel: OpenAIResponse.self)
    }
}
