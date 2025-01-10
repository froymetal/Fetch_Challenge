//
//  RecipesView.swift
//  Fetch_Challenge
//
//  Created by Froylan Almeida on 1/10/25.
//

import SwiftUI

struct RecipeListView: View {
    @StateObject private var viewModel = RecipeViewModel()

    var body: some View {
        NavigationView {
            Group {
                if let errorMessage = viewModel.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                } else {
                    List(viewModel.recipes) { recipe in
                        HStack {
                            if let photoURLSmall = recipe.photoURLSmall, let url = URL(string: photoURLSmall) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                } placeholder: {
                                    ProgressView()
                                }
                            }
                            VStack(alignment: .leading) {
                                Text(recipe.name ?? "Unknown")
                                    .font(.headline)
                                Text(recipe.cuisine ?? "Unknown Cuisine")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Recipes of the World")
            .onAppear {
                viewModel.loadRecipes()
            }
        }
    }
}

// MARK: - Vista Previa
struct RecipeListView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeListView()
    }
}
