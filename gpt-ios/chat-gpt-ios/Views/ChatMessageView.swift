//
//  ChatMessageView.swift
//  chat-gpt-ios
//
//  Created by Oscar Castillo on 1/7/24.
//

import SwiftUI

struct ChatMessagesView: View {
    let viewModel: ChatViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(viewModel.messages, id: \.self) { message in

                HStack {
                    if message.role == .user {
                        Spacer()
                    }
                    
                    let backgroundColor = message.role == .user ? Color.accentColor.opacity(0.2) : Color.softGreen.opacity(0.2)
                    Text(message.content)
                        .padding()
                        .background(backgroundColor)
                        .cornerRadius(8)
                        .foregroundColor(.primary)
                    
                    if message.role == .assistant {
                        Spacer()
                    }
                }
                .id(message)
            }
        }
    }
}
