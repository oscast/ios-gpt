//
//  AppleTTSService.swift
//  chat-gpt-ios
//
//  Created by Oscar Castillo on 5/7/24.
//

import AVFoundation

@Observable
class AppleTTSService: NSObject, AVSpeechSynthesizerDelegate, TTSServiceType {
    // Everything is optional because I had problems stopping the audio services
    private var speechSynthesizer: AVSpeechSynthesizer?
    
    override init() {
        super.init()
        initializeSynthesizer()
    }
    
    private func initializeSynthesizer() {
        speechSynthesizer = AVSpeechSynthesizer()
        speechSynthesizer?.delegate = self
    }
    
    private func activateAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.duckOthers, .defaultToSpeaker])
            try audioSession.setActive(true)
        } catch {
            debugPrint("Failed to activate audio session: \(error)")
        }
    }
    
    private func deactivateAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            debugPrint("Failed to deactivate audio session: \(error)")
        }
    }
    
    func speak(text: String) async throws {
        activateAudioSession()
        
        if speechSynthesizer == nil {
            initializeSynthesizer()
        }
        
        guard let speechSynthesizer = speechSynthesizer else {
            debugPrint("Speech synthesizer not available")
            return
        }
        guard let voice = AVSpeechSynthesisVoice(language: "en-US") else {
            debugPrint("Desired voice not available")
            return
        }
        
        let speechUtterance = AVSpeechUtterance(string: text)
        speechUtterance.voice = voice
        speechUtterance.rate = AVSpeechUtteranceDefaultSpeechRate
        speechUtterance.volume = 1.0
        speechSynthesizer.speak(speechUtterance)
        
        await withCheckedContinuation { continuation in
            self.continuation = continuation
        }
        
        deactivateAudioSessionWithDelay()
    }
    
    private var continuation: CheckedContinuation<Void, Never>?
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        continuation?.resume()
        speechSynthesizer = nil
        deactivateAudioSessionWithDelay()
    }
    
    private func deactivateAudioSessionWithDelay() {
        // I had to add this because there was a problem stopping the session as soon it finished speaking.  you have to wait until it finishes speaking completely.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.deactivateAudioSession()
        }
    }
}
