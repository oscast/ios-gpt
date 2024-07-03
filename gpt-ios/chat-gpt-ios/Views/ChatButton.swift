//
//  ChatButton.swift
//  chat-gpt-ios
//
//  Created by Oscar Castillo on 1/7/24.
//

import SwiftUI

struct ChatButton: View {
    @Bindable var viewModel: ChatViewModel
    
    var body: some View {
        HStack {
            TextField("Enter your message", text: $viewModel.inputMessage)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding([.leading, .top, .bottom])
                .onSubmit {
                    sendMessage()
                }
            
            Button(action: {
                sendMessage()
            }) {
                Image(systemName: "paperplane.fill")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding([.trailing, .top, .bottom])
        }
        .background(Color(UIColor.systemGray5))
        .cornerRadius(10)
    }
    
    func sendMessage() {
        Task {
            viewModel.isLoading = true
            await viewModel.sendMessage(stream: viewModel.shouldStream)
            viewModel.isLoading = false
        }
    }
}
