//
//  TextToSpeechService.swift
//  chat-gpt-ios
//
//  Created by Oscar Castillo on 4/7/24.
//

import AVFoundation

@Observable
class TextToSpeechService: NSObject, AVSpeechSynthesizerDelegate {
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
    
    func speak(_ text: String) {
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
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        speechSynthesizer = nil
        deactivateAudioSessionWithDelay()
    }
    
    private func deactivateAudioSessionWithDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.deactivateAudioSession()
        }
    }
}
