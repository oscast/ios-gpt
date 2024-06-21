//
//  OpenAIRequest.swift
//  chat-gpt-ios
//
//  Created by Oscar Castillo on 21/6/24.
//

import Foundation

struct OpenAIRequest: Codable {
    let model: String
    let messages: [Message]
}

struct OpenAIResponse: Codable {
    let choices: [Choice]
}
