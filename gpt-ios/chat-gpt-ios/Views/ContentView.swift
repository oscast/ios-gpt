//
//  ContentView.swift
//  chat-gpt-ios
//
//  Created by Oscar Castillo on 17/6/24.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = ChatViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollViewReader { scrollViewProxy in
                    ScrollView {
                        ChatMessagesView(viewModel: viewModel)
                            .padding()
                    }
                    .onChange(of: viewModel.messages) { _, newMessages in
                        withAnimation {
                            if let lastMessage = newMessages.last {
                                scrollViewProxy.scrollTo(lastMessage, anchor: .bottom)
                            }
                        }
                    }
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                }
                
                ChatButton(viewModel: viewModel)
                    .padding([.leading, .trailing, .bottom])
                
                Spacer()
            }
            .padding(.top)
            .navigationTitle("Chat with GPT")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ContentView()
}
