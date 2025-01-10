//
//  RecipeService.swift
//  Fetch_Challenge
//
//  Created by Froylan Almeida on 1/10/25.
//

import Foundation
import Combine

class RecipeService {
    func fetchRecipes() -> AnyPublisher<[Recipe]?, Error> {
        guard let url = URL(string: RecipeConstants.apiURL) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { output -> Data in
                guard let response = output.response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return output.data
            }
            .decode(type: RecipeResponse.self, decoder: JSONDecoder())
            .map { $0.recipes }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
