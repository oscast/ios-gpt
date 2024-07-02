//
//  Request Models.swift
//  chat-gpt-ios
//
//  Created by Oscar Castillo on 25/6/24.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

extension HTTPURLResponse {
    func toNetworkError(data: Data? = nil) -> NetworkError {
        switch statusCode {
        case 400:
            return .badRequest
        case 401:
            return .unauthenticated
        case 403:
            return .forbidden
        case 404:
            return .notFound
        case 429:
            return .exceededQuota
        case 500:
            return .internalServerError
        case 503:
            return .serviceUnavailable
        default:
            if let data = data, let message = String(data: data, encoding: .utf8) {
                return .other(message)
            }
            return .unknownError
        }
    }
}

protocol Endpoint {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var queryParams: [String: String]? { get }
    var body: Data? { get }
}

extension Endpoint {
    var urlRequest: URLRequest? {
        var urlComponents = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)
        
        if let queryParams = queryParams {
            urlComponents?.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        guard let url = urlComponents?.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body
        headers?.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        
        return request
    }
}
