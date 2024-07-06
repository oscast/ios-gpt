//
//  API Configuration.swift
//  chat-gpt-ios
//
//  Created by Oscar Castillo on 17/6/24.
//

import Foundation

struct APIConfiguration {
    static let apiKey = ""
    static let googleAPIKey = ""
    static let includeSystemRole: Bool = true
}

extension URL {
    static var openAIURL: URL {
        URL(string: "https://api.openai.com/v1/")!
    }
    
    static var googleTTSURL: URL {
        URL(string: "https://texttospeech.googleapis.com")!
    }
}
