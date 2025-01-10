//
//  RecipesViewModel.swift
//  Fetch_Challenge
//
//  Created by Froylan Almeida on 1/10/25.
//

import Foundation
import Combine

class RecipeViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()
    private let service = RecipeService()

    func loadRecipes() {
        service.fetchRecipes()
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] recipes in
                self?.recipes = recipes ?? []
            })
            .store(in: &cancellables)
    }
}
