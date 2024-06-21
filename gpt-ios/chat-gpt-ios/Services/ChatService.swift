//
//  ChatService.swift
//  chat-gpt-ios
//
//  Created by Oscar Castillo on 17/6/24.
//

import Foundation
import SwiftUI

protocol ChatStreamer {
    func sendMessage() async
}

@Observable
class ChatService: ChatStreamer {
    
    var chatMessages: [Message] = []
    var userInput: String = ""
    var isLoading: Bool = false
    
    private let gptMode: String = "gpt-4o"
    
    private let apiService: APIService
    
    init(apiService: APIService = APIService(urlSession: .shared)) {
        self.apiService = apiService
    }
    
    func sendMessage() async {
        guard !userInput.isEmpty else { return }
        
        let userMessage = Message(role: .user, content: userInput)
        chatMessages.append(userMessage)
        
        do {
            let messages = [Message(role: .user, content: userInput)]
            let openAIRequest = OpenAIRequest(model: gptMode, messages: messages)
            let request = try ChatRequest.makeRequest(openAIRequest: openAIRequest)
            
            let openAIResponse: OpenAIResponse = try await apiService.request(urlRequest: request)
            
            guard let message = openAIResponse.choices.first?.message.content else { throw NetworkError.invalidResponse }
            
            let botMessage = Message(role: .assistant, content: message)
            chatMessages.append(botMessage)
            userInput = ""
        } catch {
            if let networkError = error as? NetworkError {
                chatMessages.append(Message.ErrorMessage(error: networkError))
            } else {
                chatMessages.append(Message.ErrorMessage(error:  NetworkError.other("unkown error")))
            }
        }
    }
}
