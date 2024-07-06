//
//  TextToSpeechType.swift
//  chat-gpt-ios
//
//  Created by Oscar Castillo on 5/7/24.
//

import Foundation

protocol TTSServiceType {
    func speak(text: String) async throws
}
