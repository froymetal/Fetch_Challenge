//
//  RecipeViewModelTests.swift
//  Fetch_ChallengeTests
//
//  Created by Froylan Almeida on 1/10/25.
//

import Foundation
import Combine
import XCTest
@testable import Fetch_Challenge

class MockRecipeService: RecipeService {
    var result: Result<[Recipe]?, Error> = .success(nil)
    
    override func fetchRecipes() -> AnyPublisher<[Recipe]?, Error> {
        return Future { promise in
            promise(self.result)
        }
        .eraseToAnyPublisher()
    }
}

@MainActor
final class RecipeViewModelTests: XCTestCase {
    var viewModel: RecipeViewModel!
    var mockService: MockRecipeService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockService = MockRecipeService()
        viewModel = RecipeViewModel(service: mockService)
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testLoadRecipesWithValidData() {
        let jsonData = """
        [
            { "id": 1, "name": "Recipe 1" },
            { "id": 2, "name": "Recipe 2" }
        ]
        """.data(using: .utf8)!
        
        let recipes = try! JSONDecoder().decode([Recipe].self, from: jsonData)
        mockService.result = .success(recipes)
        
        let expectation = XCTestExpectation(description: "Load recipes successfully")
        
        viewModel.loadRecipes()

        viewModel.$recipes
            .dropFirst()
            .sink { recipes in
                XCTAssertEqual(recipes.count, 2)
                XCTAssertEqual(recipes[0].name, "Recipe 1")
                XCTAssertEqual(recipes[1].name, "Recipe 2")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLoadRecipesWithEmptyData() {
        mockService.result = .success([])
        
        let expectation = XCTestExpectation(description: "Handle empty recipes data")
        
        viewModel.loadRecipes()
        
        viewModel.$recipes
            .dropFirst()
            .sink { recipes in
                XCTAssertTrue(recipes.isEmpty)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLoadRecipesWithMalformedData() {
        mockService.result = .failure(URLError(.badServerResponse))
        
        let expectation = XCTestExpectation(description: "Handle malformed data")
        
        viewModel.loadRecipes()
        
        viewModel.$errorMessage
            .dropFirst()
            .sink { errorMessage in
                XCTAssertNotNil(errorMessage)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
}
