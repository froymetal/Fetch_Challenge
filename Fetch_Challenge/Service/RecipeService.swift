//
//  RecipeService.swift
//  Fetch_Challenge
//
//  Created by Froylan Almeida on 1/10/25.
//

import Foundation
import Combine

class RecipeService {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetchRecipes() -> AnyPublisher<[Recipe]?, Error> {
        guard let url = URL(string: RecipeConstants.apiURL) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        return session.dataTaskPublisher(for: url)
            .tryMap { output -> Data in
                guard let httpResponse = output.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return output.data
            }
            .decode(type: RecipeResponse.self, decoder: JSONDecoder())
            .map { $0.recipes }
            .eraseToAnyPublisher()
    }
}

//class RecipeService {
//    func fetchRecipes() -> AnyPublisher<[Recipe]?, Error> {
//        guard let url = URL(string: RecipeConstants.apiURL) else {
//            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
//        }
//
//        return URLSession.shared.dataTaskPublisher(for: url)
//            .tryMap { output -> Data in
//                guard let httpResponse = output.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
//                    throw URLError(.badServerResponse)
//                }
//                return output.data
//            }
//            .decode(type: RecipeResponse.self, decoder: JSONDecoder())
//            .map { $0.recipes }
//            .eraseToAnyPublisher()
//    }
//}

