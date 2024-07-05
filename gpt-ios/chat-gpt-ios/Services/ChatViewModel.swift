//
//  ChatViewModel.swift
//  chat-gpt-ios
//
//  Created by Oscar Castillo on 1/7/24.
//

import Foundation
import Observation

@Observable
class ChatViewModel {
    var messages: [Message] = []
    var inputMessage: String = ""
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var shouldStream: Bool = false
    
    private let chatService: ChatServiceType
    
    private var includeSystemRole: Bool
    
    private var lastMessageTime: Date?
    
    var displayMessages: [Message] {
        return messages.filter { $0.role != .system }
    }
    
    init(chatService: ChatServiceType = ChatService(), includeSystemRole: Bool = true) {
        self.chatService = chatService
        self.includeSystemRole = includeSystemRole
    }
    
    func sendMessage(stream: Bool = false) async {
        guard !inputMessage.isEmpty else { return }
        
        let message = Message(role: .user, content: inputMessage)
        messages.append(message)
        inputMessage = ""
        isLoading = true
        errorMessage = nil
        lastMessageTime = Date()
        
        if stream {
            chatService.streamMessage(message, includeSystemRole: includeSystemRole) { [weak self] result in
                switch result {
                case .success(let newMessage):
                    Task { @MainActor [weak self] in
                        self?.processStreamedMessage(newMessage)
                    }
                case .failure(let error):
                    Task { @MainActor [weak self] in
                        self?.errorMessage = error.localizedDescription
                    }
                }
            }
        } else {
            do {
                let response = try await chatService.sendMessage(message, includeSystemRole: includeSystemRole)
                if let reply = response.choices.first?.message {
                    messages.append(reply)
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
        
        isLoading = false
        includeSystemRole = false
    }
    
    private func processStreamedMessage(_ newMessage: Message) {
        let now = Date()
        
        let appendMessage: (Message) -> Void = { [weak self] message in
            DispatchQueue.main.async {
                if let lastTime = self?.lastMessageTime, now.timeIntervalSince(lastTime) > 1 || self?.messages.last?.role != .assistant {
                    self?.messages.append(message)
                } else if let lastIndex = self?.messages.lastIndex(where: { $0.role == .assistant }) {
                    self?.messages[lastIndex].content = message.content
                } else {
                    self?.messages.append(message)
                }
                self?.lastMessageTime = now
            }
        }
        
        let characters = Array(newMessage.content)
        var currentContent = ""
        for (index, character) in characters.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.02) { // I added a delay. openAI returns almost everything inmediately
                currentContent += String(character)
                let updatedMessage = Message(role: .assistant, content: currentContent)
                appendMessage(updatedMessage)
            }
        }
    }

}
