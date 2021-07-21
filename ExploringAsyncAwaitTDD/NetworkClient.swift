//
//  NetworkClient.swift
//  ExploringAsyncAwaitTDD
//
//  Created by Daniel Reyes Sanchez on 21/07/21.
//

import Foundation

protocol URLSessionProtocol {
    func data(for request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse)
}
extension URLSession: URLSessionProtocol { }

class NetworkClient {
    
    private let session: URLSessionProtocol
    
    private typealias URLSessionResponse = (data: Data, response: URLResponse)
    
    public enum Error: Swift.Error, Equatable {
        case invalidResponse
        case serverError(code: Int)
    }
    
    public init(session: URLSessionProtocol) {
        self.session = session
    }
    
    public func request<T: Decodable>(_ urlRequest: URLRequest) async throws -> T {
        try JSONDecoder().decode(T.self, from: try await data(from: urlRequest))
    }
    
    public func data(from request: URLRequest) async throws -> Data {
        let response: URLSessionResponse = try await session.data(for: request, delegate: nil)
        return try await validate(response: response)
    }
    
    // MARK: - Private
    
    private func validate(response: URLSessionResponse) async throws -> Data {
        guard let httpResponse = response.response as? HTTPURLResponse else {
            throw Error.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw Error.serverError(code: httpResponse.statusCode)
        }
        
        return response.data
    }
}
