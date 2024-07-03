//
//  OpenAIResponse.swift
//  chat-gpt-ios
//
//  Created by Oscar Castillo on 3/7/24.
//

import Foundation

struct OpenAIResponse: Codable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [Choice]
    let usage: Usage?
}

struct Choice: Codable {
    let index: Int
    let message: Message
    let logprobs: String?
    let finish_reason: String?
}

struct Usage: Codable {
    let prompt_tokens: Int
    let completion_tokens: Int
    let total_tokens: Int
}
