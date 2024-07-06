//
//  GoogleTTSRequest.swift
//  chat-gpt-ios
//
//  Created by Oscar Castillo on 5/7/24.
//

import Foundation

enum GoogleTTSVoice {
    case male(Male)
    case female(Female)
    
    enum Male: String, CaseIterable {
        case enUSWavenetA = "en-US-Wavenet-A"
        case enUSWavenetC = "en-US-Wavenet-C"
        case enUSWavenetE = "en-US-Wavenet-E"
        case enGBWavenetA = "en-GB-Wavenet-A"
        case enGBWavenetC = "en-GB-Wavenet-C"
    }
    
    enum Female: String, CaseIterable {
        case enUSWavenetB = "en-US-Wavenet-B"
        case enUSWavenetD = "en-US-Wavenet-D"
        case enUSWavenetF = "en-US-Wavenet-F"
        case enGBWavenetB = "en-GB-Wavenet-B"
    }
    
    var rawValue: String {
        switch self {
        case .male(let voice):
            return voice.rawValue
        case .female(let voice):
            return voice.rawValue
        }
    }
    
    static var allVoices: [String] {
        return Male.allCases.map { $0.rawValue } + Female.allCases.map { $0.rawValue }
    }
}

struct GoogleTTSEndpoint: Endpoint {
    var baseURL: URL { .googleTTSURL }
    var path: String { "/v1/text:synthesize" }
    var method: HTTPMethod { .post }
    var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }
    
    var queryParams: [String: String]? { ["key": APIConfiguration.googleAPIKey] }
    var body: Data?

    init(text: String, voice: GoogleTTSVoice = .female(.enUSWavenetF)) {
        let request = GoogleTTSRequest(
            input: .init(text: text),
            voice: .init(languageCode: "en-US", name: voice.rawValue),
            audioConfig: .init(audioEncoding: "MP3")
        )
        self.body = try? JSONEncoder().encode(request)
    }
    
}

struct GoogleTTSRequest: Codable {
    struct Input: Codable {
        let text: String
    }
    
    struct Voice: Codable {
        let languageCode: String
        let name: String
    }
    
    struct AudioConfig: Codable {
        let audioEncoding: String
    }
    
    let input: Input
    let voice: Voice
    let audioConfig: AudioConfig
}

struct GoogleTTSResponse: Codable {
    let audioContent: String
}
