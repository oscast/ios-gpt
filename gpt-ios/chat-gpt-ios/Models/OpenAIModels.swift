//
//  OpenAIModels.swift
//  chat-gpt-ios
//
//  Created by Oscar Castillo on 4/7/24.
//

import Foundation

enum OpenAIGPTModel: String {
    case gpt4 = "gpt-4"
    case gpt4Turbo = "gpt-4-turbo"
    case gpt35Turbo = "gpt-3.5-turbo"
    case gpt4o = "gpt-4o"
    
    var modelName: String {
        return self.rawValue
    }
}
