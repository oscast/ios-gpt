//
//  API Configuration.swift
//  chat-gpt-ios
//
//  Created by Oscar Castillo on 17/6/24.
//

import Foundation

struct APIConfiguration {
    static let apiKey = "YOUR API KEY HERE"
    static let openAIURL = "https://api.openai.com/v1/"
    static let includeSystemRole: Bool = true
    
    static var serviceURL: URL {
        URL(string: APIConfiguration.openAIURL)!
    }
}
