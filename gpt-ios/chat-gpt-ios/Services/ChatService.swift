//
//  ChatService.swift
//  chat-gpt-ios
//
//  Created by Oscar Castillo on 17/6/24.
//

import Foundation
import SwiftUI
import Foundation

protocol ChatServiceType {
    var networkService: RequesterType { get }
    func sendMessage(_ message: Message, includeSystemRole: Bool, stream: Bool) async throws -> OpenAIResponse
    func streamMessage(_ message: Message, includeSystemRole: Bool, onReceive: @escaping (Result<Message, Error>) -> Void)
}

struct ChatService: ChatServiceType {
    let networkService: RequesterType
    
    static var systemMessage = Message(role: .system, content: "You are a useful assistant expert on everything.")
    
    init(networkService: RequesterType = NetworkService()) {
        self.networkService = networkService
    }
    
    func sendMessage(_ message: Message, includeSystemRole: Bool = true, stream: Bool = false) async throws -> OpenAIResponse {
        var messages: [Message] = [message]
        
        if includeSystemRole {
            messages.insert(ChatService.systemMessage, at: 0)
        }
        
        let request = OpenAIRequest(
            model: OpenAIGPTModel.gpt35Turbo.modelName,
            messages: messages,
            stream: stream
        )
        
        let endpoint = try OpenAIEndpoint(request: request)
        
        if stream {
            // I don't think this will happen ever. I have to validate first.
            return OpenAIResponse(id: "", object: "", created: 0, model: "", choices: [], usage: nil)
        } else {
            return try await networkService.request(endpoint: endpoint, responseModel: OpenAIResponse.self)
        }
    }
    
    func streamMessage(_ message: Message, includeSystemRole: Bool, onReceive: @escaping (Result<Message, Error>) -> Void) {
        var messages: [Message] = [message]
        
        if includeSystemRole {
            messages.insert(ChatService.systemMessage, at: 0)
        }
        
        let request = OpenAIRequest(
            model: "gpt-3.5-turbo",
            messages: messages,
            stream: true
        )
        
        let endpoint = try? OpenAIEndpoint(request: request)
        
        guard let endpoint = endpoint else {
            onReceive(.failure(NetworkError.invalidURL))
            return
        }
        
        networkService.streamRequest(endpoint: endpoint, onReceive: onReceive)
    }
}
