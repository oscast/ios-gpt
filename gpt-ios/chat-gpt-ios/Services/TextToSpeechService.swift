//
//  TextToSpeechService.swift
//  chat-gpt-ios
//
//  Created by Oscar Castillo on 4/7/24.
//

import AVFoundation

@Observable
class TextToSpeechService {
    private var ttsService: TTSServiceType
    
    init(serviceType: TTSProvider = .apple) {
        self.ttsService = TextToSpeechService.createService(for: serviceType)
    }
    
    private static func createService(for type: TTSProvider) -> TTSServiceType {
        switch type {
        case .apple:
            return AppleTTSService()
        case .google:
            return GoogleTTSService()
        case .openAI:
            return OpenAITTSService()
        }
    }
    
    func setServiceType(_ type: TTSProvider) {
        self.ttsService = TextToSpeechService.createService(for: type)
    }
    
    func speak(text: String) {
        Task {
            do {
                try await ttsService.speak(text: text)
            } catch {
                print("TTS error: \(error.localizedDescription)")
            }
        }
    }
}
