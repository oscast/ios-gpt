//
//  OpenAIRequest.swift
//  chat-gpt-ios
//
//  Created by Oscar Castillo on 21/6/24.
//

import Foundation

enum UserRole: String, Codable {
    case system
    case user
    case assistant
}

struct Message: Codable, Equatable, Hashable {
    let id = UUID()
    let role: UserRole
    var content: String
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.role == rhs.role && lhs.content == rhs.content
    }
    
    enum CodingKeys: CodingKey {
        case role
        case content
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.role = try container.decode(UserRole.self, forKey: .role)
        self.content = try container.decode(String.self, forKey: .content)
    }
    
    init(role: UserRole, content: String) {
        self.role = role
        self.content = content
    }
}


struct OpenAIRequest: Codable {
    let model: String
    let messages: [Message]
    let max_tokens: Int?
    let temperature: Double?
    let top_p: Double?
    let n: Int?
    let stream: Bool?
    let logprobs: Int?
    let stop: [String]?
    
    static let defaultMaxTokens: Int = 150
    static let defaultTemperature: Double = 0.7
    static let defaultTopP: Double = 1.0
    static let defaultN: Int = 1
    static let defaultStream: Bool = false
    static let defaultLogprobs: Int? = nil
    static let defaultStop: [String]? = nil
    
    init(model: String,
         messages: [Message],
         max_tokens: Int? = OpenAIRequest.defaultMaxTokens,
         temperature: Double? = OpenAIRequest.defaultTemperature,
         top_p: Double? = OpenAIRequest.defaultTopP,
         n: Int? = OpenAIRequest.defaultN,
         stream: Bool? = OpenAIRequest.defaultStream,
         logprobs: Int? = OpenAIRequest.defaultLogprobs,
         stop: [String]? = OpenAIRequest.defaultStop) {
        self.model = model
        self.messages = messages
        self.max_tokens = max_tokens
        self.temperature = temperature
        self.top_p = top_p
        self.n = n
        self.stream = stream
        self.logprobs = logprobs
        self.stop = stop
    }
}

struct OpenAIEndpoint: Endpoint {
    var baseURL: URL { APIConfiguration.serviceURL }
    var path: String { "/chat/completions" }
    var method: HTTPMethod { .post }
    var headers: [String: String]? { ["Authorization": "Bearer \(APIConfiguration.apiKey)", "Content-Type": "application/json"] }
    var queryParams: [String: String]? { nil }
    var body: Data?
    
    init(request: OpenAIRequest) throws {
        self.body = try JSONEncoder().encode(request)
    }
}
