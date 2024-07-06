//
//  OpenAITTSRequest.swift
//  chat-gpt-ios
//
//  Created by Oscar Castillo on 5/7/24.
//

import Foundation

enum OpenAITTSModel: String, Codable {
    case tts1 = "tts-1"
    case tts1HD = "tts-1-hd"
}

enum OpenAITTSVoice: String, Codable {
    case alloy, echo, fable, onyx, nova, shimmer
}

enum OpenAIResponseFormat: String, Codable {
    case mp3, opus, aac, flac, wav, pcm
}


struct OpenAITTSEndpoint: Endpoint {
    var baseURL: URL {
        return URL(string: "https://api.openai.com/v1/")!
    }
    
    var path: String {
        return "audio/speech"
    }
    
    var method: HTTPMethod {
        return .post
    }
    
    var headers: [String: String]? {
        return [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(APIConfiguration.apiKey)"
        ]
    }
    
    var queryParams: [String: String]? {
        return nil
    }
    
    var body: Data?
    
    init(request: OpenAITTSRequest) {
        self.body = try? JSONEncoder().encode(request)
    }
}

struct OpenAITTSRequest: Codable {
    let model: OpenAITTSModel
    let input: String
    let voice: OpenAITTSVoice
    let response_format: OpenAIResponseFormat?
    let speed: Double?
    
    init(model: OpenAITTSModel, input: String, voice: OpenAITTSVoice, responseFormat: OpenAIResponseFormat? = .aac, speed: Double? = 1.0) {
        self.model = model
        self.input = input
        self.voice = voice
        self.response_format = responseFormat
        self.speed = speed
    }
}
