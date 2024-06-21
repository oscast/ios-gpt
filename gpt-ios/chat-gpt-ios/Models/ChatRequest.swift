//
//  ChatRequest.swift
//  chat-gpt-ios
//
//  Created by Oscar Castillo on 21/6/24.
//

import Foundation

struct ChatRequest {
    static let method = "POST"
    static let path = "chat/completions"
    static let baseURL = APIConfiguration.serviceURL
    
    static func makeRequest(openAIRequest: OpenAIRequest) throws -> URLRequest {
        guard let url = URL(string: baseURL.absoluteString + path) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(APIConfiguration.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let httpBody = try? JSONEncoder().encode(openAIRequest) else {
            throw NetworkError.badRequest
        }
        
        request.httpBody = httpBody
        
        return request
    }
}
