//
//  API Configuration.swift
//  chat-gpt-ios
//
//  Created by Oscar Castillo on 17/6/24.
//

import Foundation

struct APIConfiguration {
    static let apiKey = ""
    static let openAIURL = "https://api.openai.com/v1/"
    
    static var serviceURL: URL {
        URL(string: APIConfiguration.openAIURL)!
    }
}
