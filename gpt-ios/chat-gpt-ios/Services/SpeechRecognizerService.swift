//
//  SpeechService.swift
//  chat-gpt-ios
//
//  Created by Oscar Castillo on 3/7/24.
//

import AVFoundation
import Speech

@Observable
class SpeechRecognizerService: NSObject, ObservableObject {
    @ObservationIgnored
    private var audioEngine: AVAudioEngine?
    @ObservationIgnored
    private var recognitionTask: SFSpeechRecognitionTask?
    @ObservationIgnored
    private var speechRecognizer: SFSpeechRecognizer?
    
    var isRecording = false
    var recognizedText = ""
    
    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            debugPrint("Failed to set up audio session for recording: \(error)")
            return
        }
        
        audioEngine = AVAudioEngine()
        speechRecognizer = SFSpeechRecognizer()
        
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            debugPrint("Speech recognizer is not available")
            return
        }
        
        let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let audioEngine = audioEngine else {
            fatalError("Audio engine not initialized")
        }
        
        let inputNode = audioEngine.inputNode
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            if let result = result {
                self.recognizedText = result.bestTranscription.formattedString
            }
            if let error = error {
                debugPrint("Speech recognition error: \(error)")
                self.handleRecognitionError(error)
            }
            if result?.isFinal == true {
                self.stopRecording()
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, when in
            recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
            isRecording = true
        } catch {
            debugPrint("Audio engine couldn't start: \(error)")
        }
    }
    
    func stopRecording() {
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        recognitionTask?.cancel()
        recognitionTask = nil
        audioEngine = nil
        speechRecognizer = nil
        isRecording = false
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            debugPrint("Failed to deactivate audio session: \(error)")
        }
    }
    
    private func handleRecognitionError(_ error: Error) {
        stopRecording()
        if let nsError = error as NSError?, nsError.domain == "kAFAssistantErrorDomain" && nsError.code == 1110 {
            debugPrint("No speech detected")
        } else {
            debugPrint("Unexpected error: \(error.localizedDescription)")
        }
    }
}
