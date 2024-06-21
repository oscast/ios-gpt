//
//  Message.swift
//  chat-gpt-ios
//
//  Created by Oscar Castillo on 21/6/24.
//

import Foundation

enum Role: String, Codable {
    case user
    case assistant
}

struct Message: Codable, Identifiable, Hashable {
    let id = UUID()
    let role: Role
    let content: String
    
    init(role: Role, content: String) {
        self.role = role
        self.content = content
    }
    
    enum CodingKeys: CodingKey {
        case role
        case content
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.role = try container.decode(Role.self, forKey: .role)
        self.content = try container.decode(String.self, forKey: .content)
    }
    
    static func ErrorMessage(error: NetworkError) -> Message {
        Message(role: .assistant, content: error.localizedDescription)
    }
}

struct Choice: Codable {
    let message: Message
}
