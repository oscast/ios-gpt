//
//  OpenAITTSService.swift
//  chat-gpt-ios
//
//  Created by Oscar Castillo on 5/7/24.
//

import Foundation

class OpenAITTSService: TTSServiceType {
    private let networkService: RequesterType
    
    init(networkService: RequesterType = NetworkService()) {
        self.networkService = networkService
    }
    
    func speak(text: String) async throws {
        let request = OpenAITTSRequest(model: .tts1, input: text, voice: .nova, responseFormat: .aac)
        let endpoint = OpenAITTSEndpoint(request: request)
        
        let data = try await networkService.requestData(endpoint: endpoint)
        
        let temporaryDirectory = FileManager.default.temporaryDirectory
        let temporaryFileURL = temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("aac")
        
        try data.write(to: temporaryFileURL)
        AudioPlayerManager.shared.playAudio(from: temporaryFileURL)
    }
}
