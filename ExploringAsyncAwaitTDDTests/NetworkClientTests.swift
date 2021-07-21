//
//  NetworkClientTests.swift
//  ExploringAsyncAwaitTDDTests
//
//  Created by Daniel Reyes Sanchez on 21/07/21.
//

import XCTest
@testable import ExploringAsyncAwaitTDD

class NetworkClientTests: XCTestCase {
    
    func test_fetchValidResponseFromClient_deliversData() async {
        let session = URLSessionStub()
        session.mockResponse = ("someData".data(using: .utf8)!, makeResponse(code: 200))
        let sut = NetworkClient(session: session)
        let urlRequest = makeRequest()
        
        do {
            let data = try await sut.data(from: urlRequest)
            XCTAssertNotNil(data)
        } catch {
            XCTFail("No present data: \(error)")
        }
        // MARK: since `XCTAssertNoThrow` does not support async yet, do catch is the only way for now
        // XCTAssertNoThrow( async {
        //    try await sut.data(from: urlRequest)
        // })
    }
    
    func test_fetchInvalidResponseFromClient_deliversExpectedError() async {
        let session = URLSessionStub()
        session.mockResponse = ("someData".data(using: .utf8)!, makeResponse(code: 500))
        let sut = NetworkClient(session: session)
        let urlRequest = makeRequest()
        
        do {
            let data = try await sut.data(from: urlRequest)
            XCTAssertNil(data)
        } catch {
            XCTAssertEqual(error as? NetworkClient.Error, .serverError(code: 500))
        }
    }
    
    func test_parsesValidDataFromClient_deliversParsedModels() async {
        let session = URLSessionStub()
        session.mockResponse = (DataLoader().loadData(from: "languages"), makeResponse(code: 200))
        let sut = NetworkClient(session: session)
        let urlRequest = makeRequest()
        
        do {
            let models: [Languages] = try await sut.request(urlRequest)
            XCTAssertEqual(models.count, 4)
        } catch {
            XCTFail("No present data: \(error)")
        }
    }
    
    
    // MARK: - Helpers
    
    private func makeURL() -> URL {
        URL(string: "https://something.com")!
    }
    
    private func makeRequest() -> URLRequest {
        URLRequest(url: makeURL())
    }
    
    private func makeResponse(code: Int) -> HTTPURLResponse {
        HTTPURLResponse(
            url: makeURL(),
            statusCode: code,
            httpVersion: nil,
            headerFields: [:]
        )!
    }
    
    private struct Languages: Decodable {
        let id: Int
        let name: String
    }
}


final class URLSessionStub: URLSessionProtocol {
    
    var mockResponse: URLSessionResponse?
    
    enum Error: Swift.Error {
        case noResponse
    }
    
    func data(for request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse) {
        guard let response = mockResponse else {
            throw Error.noResponse
        }
        sleep(1)
        return response
    }
}
