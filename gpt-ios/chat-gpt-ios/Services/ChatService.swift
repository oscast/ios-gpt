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
            let openAIRequest = OpenAIRequest(model: "gpt-4o", messages: messages)
            let request = try ChatRequest.makeRequest(openAIRequest: openAIRequest)
            
            let response: String = try await apiService.request(urlRequest: request)
            let botMessage = Message(role: .assistant, content: response)
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


