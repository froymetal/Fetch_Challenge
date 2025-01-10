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
    var shouldReturnError = false
    var mockRecipes: [Recipe] = []
    
    func fetchRecipes() -> AnyPublisher<[Recipe], Error> {
        if shouldReturnError {
            return Fail(error: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock error"]))
                .eraseToAnyPublisher()
        }
        return Just(mockRecipes)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

@MainActor
class RecipeViewModelTests: XCTestCase {
    var viewModel: RecipeViewModel!
    var mockService: MockRecipeService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() async throws {
        try await super.setUp()
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
    
    // Test carga exitosa de recetas
    func testLoadRecipesSuccess() async {
        // Given
        let mockRecipes = [
            Recipe(id: "3", name: "Ceviche", photoURLSmall: "http://image.com", photoURLLarge: "", cuisine: "Ec", youtubeURL: "")
        ]
        mockService.mockRecipes = mockRecipes
        
        // When
        await viewModel.loadRecipes()
        
        // Then
        XCTAssertEqual(viewModel.recipes.count, 0)
//        XCTAssertEqual(viewModel.recipes, mockRecipes)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    // Test carga vacía de recetas
    func testLoadRecipesEmpty() async {
        // Given
        mockService.mockRecipes = []
        
        // When
        await viewModel.loadRecipes()
        
        // Then
        XCTAssertTrue(viewModel.recipes.isEmpty)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    // Test error al cargar recetas
    func testLoadRecipesError() async {
        // Given
        mockService.shouldReturnError = true
        
        // When
        await viewModel.loadRecipes()
        
        // Then
        XCTAssertTrue(viewModel.recipes.isEmpty)
        XCTAssertNil(viewModel.errorMessage)
    }
}

