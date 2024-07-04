//
//  ContentView.swift
//  chat-gpt-ios
//
//  Created by Oscar Castillo on 17/6/24.
//

import SwiftUI
import AVFAudio

struct ContentView: View {
    @State private var viewModel = ChatViewModel()
    
    @State private var speechRecognizer = SpeechRecognizerService()
    @State private var speechSynthesizerService = TextToSpeechService()
    @State private var showingTextField = false
    @State private var speechText: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                
                Toggle(isOn: $viewModel.shouldStream, label: {
                    HStack {
                        Spacer()
                        Text("Stream")
                    }
                })
                .padding(.horizontal)
                
                Divider()
                
                ScrollViewReader { scrollViewProxy in
                    ScrollView {
                        ChatMessagesView(viewModel: viewModel)
                            .padding()
                    }
                    .onChange(of: viewModel.messages) { _, newMessages in
                        withAnimation {
                            if let lastMessage = newMessages.last {
                                  scrollViewProxy.scrollTo(lastMessage, anchor: .bottom)
                                  if lastMessage.role == .assistant {
                                      speechSynthesizerService.speak(lastMessage.content)
                                  }
                              }
                        }
                    }
                    .onTapGesture {
                        showingTextField = false
                    }
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                }
                
                if showingTextField == false {
                    HStack {
                        
                        showKeyboardButton()

                        Spacer()
                        
                        microphoneButton()
                        
                    }
                    .padding()
                }
                
                if showingTextField {
                    ChatButton(viewModel: viewModel)
                        .padding([.leading, .trailing, .bottom])
                }
                
                Spacer()
            }
            .onChange(of: speechRecognizer.recognizedText) { _, newText in
                print("Recognized text: \(newText)")
            }
            .onChange(of: speechRecognizer.isRecording) { _, newValue in
                if newValue == false {
                    Task {
                        viewModel.inputMessage = speechRecognizer.recognizedText
                        await viewModel.sendMessage()
                    }
                }
            }
            .padding(.top)
            .navigationTitle("Chat with GPT")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func handleLastMessage() {
        
    }
    
    @ViewBuilder
    func showKeyboardButton() -> some View {
        Button(action: {
            showingTextField.toggle()
        }) {
            Image(systemName: "keyboard")
                .font(.largeTitle)
                .padding()
                .foregroundColor(.accentColor)
        }
    }
    
    @ViewBuilder
    func microphoneButton() -> some View {
        ZStack {
            
            Circle()
                .fill(Color.accentColor)
                .frame(width: 100, height: 100)
                .scaleEffect(speechRecognizer.isRecording  ? 1.2 : 1.0)
                .opacity(speechRecognizer.isRecording  ? 0.2 : 0.0)
                .animation(speechRecognizer.isRecording  ? Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true) : .default, value: speechRecognizer.isRecording )
            
            Button(action: {
                speechRecognizer.isRecording ? speechRecognizer.stopRecording() : speechRecognizer.startRecording()
            }) {
                Image(systemName: speechRecognizer.isRecording ? "mic.circle.fill" : "mic.circle")
                    .font(.system(size: 64))
                    .padding()
                    .foregroundColor(.accentColor)
            }
            
        }
    }
}

#Preview {
    ContentView()
}
