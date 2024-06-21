//
//  ContentView.swift
//  chat-gpt-ios
//
//  Created by Oscar Castillo on 17/6/24.
//

import SwiftUI

struct ContentView: View {
    @State private var service = ChatService()
    
    var body: some View {
        NavigationView {
            VStack {
                
                ScrollViewReader { scrollViewProxy in
                    ScrollView {
                        ChatMessagesView()
                            .padding()
                    }
                    .onChange(of: service.chatMessages) { _, newMessages in
                        withAnimation {
                            if let lastMessage = newMessages.last {
                                scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                .environment(service)
                
                if service.isLoading {
                    ProgressView()
                        .padding()
                }
                
                chatButton(service: service)
                    .padding([.leading, .trailing, .bottom])
                
                Spacer()
            }
            .padding(.top)
            .navigationTitle("Chat with GPT")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    struct ChatMessagesView: View {
        @Environment(ChatService.self) var service
        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(service.chatMessages) { message in
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
                    .id(message.id)
                }
            }
        }
    }
    
    struct chatButton: View {
        
        @Bindable var service: ChatService
        
        var body: some View {
            HStack {
                TextField("Enter your message", text: $service.userInput)
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
            .background(Color(UIColor.systemGray6))
            .cornerRadius(10)
        }
        
        func sendMessage() {
            Task {
                service.isLoading = true
                await service.sendMessage()
                service.isLoading = false
            }
        }
    }
}

#Preview {
    ContentView()
}
