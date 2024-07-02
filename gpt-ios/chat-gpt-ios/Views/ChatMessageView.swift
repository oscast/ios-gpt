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
                    
                    let color = message.role == .user ? Color.blue : Color.gray
                    Text(message.content)
                        .padding()
                        .background(color.opacity(0.2))
                        .cornerRadius(8)
                        .foregroundColor(.black)
                    
                    if message.role == .assistant {
                        Spacer()
                    }
                }
                .id(message)
            }
        }
    }
}
