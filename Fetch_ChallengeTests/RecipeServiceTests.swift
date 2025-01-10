//
//  RecipeServiceTests.swift
//  Fetch_Challenge
//
//  Created by Froylan Almeida on 1/10/25.
//

import Foundation
import Combine
import XCTest
@testable import Fetch_Challenge

class MockURLProtocol: URLProtocol {
    static var response: (data: Data?, response: URLResponse?, error: Error?)?
    
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        if let error = MockURLProtocol.response?.error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            if let data = MockURLProtocol.response?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            if let response = MockURLProtocol.response?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
    }
    override func stopLoading() {}
}

@MainActor
final class RecipeServiceTests: XCTestCase {
    var service: RecipeService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        service = RecipeService(session: session) // Ahora el inicializador acepta `session`.
        cancellables = []
    }
    
    override func tearDown() {
        service = nil
        cancellables = nil
        MockURLProtocol.response = nil
        super.tearDown()
    }
    
    private func setMockResponse(data: Data?, statusCode: Int, error: Error?) {
        let url = URL(string: RecipeConstants.apiURL)!
        MockURLProtocol.response = (
            data: data,
            response: HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil),
            error: error
        )
    }
    
    func testFetchRecipesSuccess() {
        let jsonData = """
        { "recipes": [{ "id": 1, "name": "Recipe 1" }] }
        """.data(using: .utf8)
        setMockResponse(data: jsonData, statusCode: 200, error: nil)
        
        let expectation = expectation(description: "Fetch recipes successfully")
        service.fetchRecipes()
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail("Expected success")
                }
            }, receiveValue: { recipes in
                XCTAssertEqual(recipes?.count, 1)
                XCTAssertEqual(recipes?.first?.name, "Recipe 1")
                expectation.fulfill()
            })
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 1)
    }
    
    func testFetchRecipesEmpty() {
        let jsonData = """
        { "recipes": [] }
        """.data(using: .utf8)
        setMockResponse(data: jsonData, statusCode: 200, error: nil)
        
        let expectation = expectation(description: "Handle empty recipes")
        service.fetchRecipes()
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail("Expected success")
                }
            }, receiveValue: { recipes in
                XCTAssertTrue(recipes?.isEmpty ?? false)
                expectation.fulfill()
            })
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 1)
    }
    
    func testFetchRecipesMalformed() {
        setMockResponse(data: "malformed".data(using: .utf8), statusCode: 200, error: nil)
        
        let expectation = expectation(description: "Handle malformed data")
        service.fetchRecipes()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTAssertNotNil(error)
                    expectation.fulfill()
                }
            }, receiveValue: { _ in
                XCTFail("Expected failure")
            })
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 1)
    }
    
    func testFetchRecipesNetworkError() {
        setMockResponse(data: nil, statusCode: 500, error: URLError(.timedOut))
        
        let expectation = expectation(description: "Handle network error")
        service.fetchRecipes()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTAssertNotNil(error)
                    expectation.fulfill()
                }
            }, receiveValue: { _ in
                XCTFail("Expected failure")
            })
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 1)
    }
}
