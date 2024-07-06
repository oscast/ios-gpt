//
//  GoogleTTSService.swift
//  chat-gpt-ios
//
//  Created by Oscar Castillo on 5/7/24.
//

import Foundation

class GoogleTTSService: TTSServiceType {
    private let networkService: RequesterType
    
    init(networkService: RequesterType = NetworkService()) {
        self.networkService = networkService
    }
    
    func speak(text: String) async throws {
        let endpoint = GoogleTTSEndpoint(text: text)
        let response: GoogleTTSResponse = try await networkService.request(endpoint: endpoint, responseModel: GoogleTTSResponse.self)
        
        guard let audioData = Data(base64Encoded: response.audioContent) else {
            throw NSError(domain: "GoogleTTSService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode audio content"])
        }
        
        let temporaryDirectory = FileManager.default.temporaryDirectory
        let temporaryFileURL = temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("mp3")
        
        try audioData.write(to: temporaryFileURL)
        AudioPlayerManager.shared.playAudio(from: temporaryFileURL)
    }
}
