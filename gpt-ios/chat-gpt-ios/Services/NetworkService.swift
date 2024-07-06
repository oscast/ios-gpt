//
//  NetworkService.swift
//  chat-gpt-ios
//
//  Created by Oscar Castillo on 3/7/24.
//

import Foundation

protocol NetworkSession {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
    func streamData(for request: URLRequest, onReceive: @escaping (Result<Data, Error>) -> Void)
}

extension URLSession: NetworkSession {
    func streamData(for request: URLRequest, onReceive: @escaping (Result<Data, Error>) -> Void) {
        let task = dataTask(with: request) { data, response, error in
            if let error = error {
                onReceive(.failure(error))
                return
            }
            
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                onReceive(.failure(NetworkError.invalidResponse))
                return
            }
            
            if let data = data {
                onReceive(.success(data))
            } else {
                onReceive(.failure(NetworkError.invalidResponse))
            }
        }
        task.resume()
    }
}

protocol RequesterType {
    func request<T: Decodable>(endpoint: Endpoint, responseModel: T.Type) async throws -> T
    func streamRequest(endpoint: Endpoint, onReceive: @escaping (Result<Message, Error>) -> Void)
    func requestData(endpoint: Endpoint) async throws -> Data
}

class NetworkService: RequesterType {
    private let session: NetworkSession
    
    init(session: NetworkSession = URLSession.shared) {
        self.session = session
    }
    
    func request<T: Decodable>(endpoint: Endpoint, responseModel: T.Type) async throws -> T {
        guard let request = endpoint.urlRequest else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw httpResponse.toNetworkError(data: data)
        }
        
        do {
            let decodedResponse = try JSONDecoder().decode(T.self, from: data)
            return decodedResponse
        } catch {
            throw NetworkError.decodeFailed
        }
    }
    
    func requestData(endpoint: Endpoint) async throws -> Data {
        guard let request = endpoint.urlRequest else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw httpResponse.toNetworkError(data: data)
        }
        
        return data
    }
    
    func streamRequest(endpoint: Endpoint, onReceive: @escaping (Result<Message, Error>) -> Void) {
        guard let request = endpoint.urlRequest else {
            onReceive(.failure(NetworkError.invalidURL))
            return
        }
        
        session.streamData(for: request) { result in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let buffer = String(decoding: data, as: UTF8.self).split(separator: "\n")
                var currentContent = ""
                
                for line in buffer {
                    guard line.hasPrefix("data:") else { continue }
                    let jsonString = line.dropFirst(5).trimmingCharacters(in: .whitespaces)
                    
                    if jsonString == "[DONE]" {
                        onReceive(.success(Message(role: .assistant, content: currentContent)))
                        break
                    }
                    
                    guard let messageData = jsonString.data(using: .utf8) else { continue }
                    do {
                        let chunk = try decoder.decode(OpenAIStreamingChunk.self, from: messageData)
                        if let delta = chunk.choices.first?.delta.content {
                            currentContent += delta
                            let message = Message(role: .assistant, content: currentContent)
                            onReceive(.success(message))
                        }
                        if chunk.choices.first?.finish_reason == "stop" {
                            break
                        }
                    } catch {
                        onReceive(.failure(NetworkError.decodeFailed))
                    }
                }
            case .failure(let error):
                onReceive(.failure(error))
            }
        }
    }
}
