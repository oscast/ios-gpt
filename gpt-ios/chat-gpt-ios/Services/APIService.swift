//
//  APIService.swift
//  chat-gpt-ios
//
//  Created by Oscar Castillo on 21/6/24.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case exceededQuota
    case invalidURL
    case invalidResponse
    case badRequest
    case unauthenticated
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
        case .unauthenticated:
            return "Your OPEN AI Token is invalid"
        case .other(let message):
            return "Something ocurred \(message)"
        }
    }
}

class APIService {
    
    let urlSession: URLSession
    
    init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }
    
    func request<T: Decodable>(urlRequest: URLRequest) async throws -> T {
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
         case 200...299:
             return try JSONDecoder().decode(T.self, from: data)
         case 401:
             throw NetworkError.unauthenticated
         case 429:
             throw NetworkError.exceededQuota
         default:
             throw NetworkError.invalidResponse
         }
    }
}
