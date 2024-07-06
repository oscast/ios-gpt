//
//  AudioPlayer.swift
//  chat-gpt-ios
//
//  Created by Oscar Castillo on 6/7/24.
//

import AVFoundation

class AudioPlayerManager: NSObject, AVAudioPlayerDelegate {
    static let shared = AudioPlayerManager()
    private var audioPlayer: AVAudioPlayer?
    
    private override init() {
        super.init()
    }
    
    func playAudio(from url: URL, volume: Float = 1.0) {
        activateAudioSession()
        do {
            let data = try Data(contentsOf: url)
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.delegate = self
            audioPlayer?.volume = volume
            audioPlayer?.play()
        } catch {
            print("Failed to play audio: \(error.localizedDescription)")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        deactivateAudioSession()
    }
    
    private func activateAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [.duckOthers])
            try audioSession.setActive(true)
        } catch let error as NSError {
            print("Failed to activate audio session: \(error), \(error.userInfo)")
        }
    }
    
    private func deactivateAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to deactivate audio session: \(error.localizedDescription)")
        }
    }
}

