//
//  ChatService.swift
//  chat-gpt-ios
//
//  Created by Oscar Castillo on 17/6/24.
//

import Foundation
import SwiftUI

protocol ChatStreamer {
    func sendMessage(message: String) async throws -> String
}

enum NetworkError: Error, LocalizedError {
    case exceededQuota
    case invalidURL
    case invalidResponse
    case badRequest
    case other(String)
    
    var errorDescription: String? {
        switch self {
        case .exceededQuota:
            return "You have exceeded your quota. Please check your plan and billing details."
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid Response"
        case .badRequest:
            return "Request is not correct"
        case .other(let message):
            return "Something ocurred \(message)"
        }
    }
}

@Observable class ChatService: ChatStreamer {
    
    var chatMessages: [Message] = []
    var userInput: String = ""
    var isLoading: Bool = false
    
    func sendMessage() async {
        guard !userInput.isEmpty else { return }
        
        let userMessage = Message(role: .user, content: userInput)
        chatMessages.append(userMessage)
        
        do {
            let response = try await sendMessage(message: userInput)
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
    
    func sendMessage(message: String) async throws -> String {
        let messages = [Message(role: .user, content: message)]
        let openAIRequest = OpenAIRequest(model: "gpt-4o", messages: messages)
        let request = try ChatRequest.makeRequest(openAIRequest: openAIRequest)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        if httpResponse.statusCode == 429 {
            throw NetworkError.exceededQuota
        }
        
        if let openAIResponse = try? JSONDecoder().decode(OpenAIResponse.self, from: data),
           let message = openAIResponse.choices.first?.message.content {
            return message
        } else {
            throw NetworkError.invalidResponse
        }
    }
}


