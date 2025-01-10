//
//  RecipesViewModel.swift
//  Fetch_Challenge
//
//  Created by Froylan Almeida on 1/10/25.
//

import Foundation
import Combine

@MainActor
class RecipeViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var errorMessage: String?

    private let service = RecipeService()
    private var cancellables = Set<AnyCancellable>()

    func loadRecipes() {
        service.fetchRecipes()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                case .finished:
                    self?.errorMessage = nil
                }
            }, receiveValue: { [weak self] recipes in
                self?.recipes = recipes ?? []
            })
            .store(in: &cancellables)
    }
}
