//
//  OpenAIChunkResponse.swift
//  chat-gpt-ios
//
//  Created by Oscar Castillo on 3/7/24.
//

import Foundation

struct OpenAIStreamingChunk: Codable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let system_fingerprint: String?
    let choices: [OpenAIStreamingChoice]
}

struct OpenAIStreamingChoice: Codable {
    let index: Int
    let delta: OpenAIStreamingDelta
    let logprobs: String?
    let finish_reason: String?
}

struct OpenAIStreamingDelta: Codable {
    let role: String?
    let content: String?
}

