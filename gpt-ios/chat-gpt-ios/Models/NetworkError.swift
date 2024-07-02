//
//  NetworkError.swift
//  chat-gpt-ios
//
//  Created by Oscar Castillo on 1/7/24.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case exceededQuota
    case invalidURL
    case invalidResponse
    case badRequest
    case unauthorized
    case notFound
    case forbidden
    case decodeFailed
    case unauthenticated
    case internalServerError
    case serviceUnavailable
    case unknownError
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
        case .decodeFailed:
            return "Failed to decode the response data"
        case .unauthorized:
            return "Error, you are not authorized"
        case .notFound:
            return "The request path was not found"
        case .forbidden:
            return "Error, forbidden access"
        case .internalServerError:
            return "Internal Server Error"
        case .serviceUnavailable:
            return "serviceUnavailable"
        case .unknownError:
            return "unknownError"
        case .other(let message):
            return "Something ocurred \(message)"
        }
    }
}
