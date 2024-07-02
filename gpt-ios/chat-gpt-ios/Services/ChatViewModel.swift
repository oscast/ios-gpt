//
//  ChatViewModel.swift
//  chat-gpt-ios
//
//  Created by Oscar Castillo on 1/7/24.
//

import Foundation

@Observable
class ChatViewModel {
    var messages: [Message] = []
    var inputMessage: String = ""
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    @ObservationIgnored
    private let chatService: ChatServiceType
    @ObservationIgnored
    private var includeSystemRole: Bool
    
    var displayMessages: [Message] {
        return messages.filter { $0.role != .system }
    }
    
    init(chatService: ChatServiceType = ChatService(), includeSystemRole: Bool = true) {
        self.chatService = chatService
        self.includeSystemRole = includeSystemRole
    }
    
    func sendMessage() async {
        guard !inputMessage.isEmpty else { return }
        
        let message = Message(role: .user, content: inputMessage)
        messages.append(message)
        inputMessage = ""
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await chatService.sendMessage(message, includeSystemRole: includeSystemRole, stream: false)
            if let reply = response.choices.first?.message {
                
                await MainActor.run { [weak self] in
                    self?.messages.append(reply)
                }
            }
        } catch {
            await MainActor.run { [weak self] in
                self?.errorMessage = error.localizedDescription // Set the error message
            }
        }
        
        isLoading = false
        includeSystemRole = false
    }
}
