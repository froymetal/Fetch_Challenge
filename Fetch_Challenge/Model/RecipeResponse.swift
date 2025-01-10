//
//  Recipes.swift
//  Fetch_Challenge
//
//  Created by Froylan Almeida on 1/10/25.
//

import Foundation

struct RecipeResponse: Codable {
    let recipes: [Recipe]?
}

struct Recipe: Identifiable, Codable {
    let id: String?
    let name: String?
    let photoURLSmall: String?
    let photoURLLarge: String?
    let cuisine: String?
    let youtubeURL: String?

    enum CodingKeys: String, CodingKey {
        case id = "uuid"
        case name
        case photoURLSmall = "photo_url_small"
        case photoURLLarge = "photo_url_large"
        case cuisine
        case youtubeURL = "youtube_url"
    }
}
