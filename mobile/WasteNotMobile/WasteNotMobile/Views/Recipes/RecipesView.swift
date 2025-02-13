//
//  RecipesView.swift
//  WasteNotMobile
//
//  Created by Ethan Yan on 12/2/25.
//

import SwiftUI

struct Recipe: Identifiable {
    let id = UUID()
    let name: String
    let ingredients: [String]
    let missingIngredients: [String]
}

struct RecipesView: View {
    let recipes = [
        Recipe(name: "Spinach Omelet", ingredients: ["Eggs", "Spinach", "Milk"], missingIngredients: ["Milk"]),
        Recipe(name: "Cheese Sandwich", ingredients: ["Bread", "Cheese", "Butter"], missingIngredients: ["Cheese"]),
        Recipe(name: "Fruit Salad", ingredients: ["Apple", "Banana", "Orange"], missingIngredients: [])
    ]
    
    var body: some View {
        VStack {
            // Removed duplicate title text here
            
            List(recipes) { recipe in
                VStack(alignment: .leading, spacing: 5) {
                    Text(recipe.name)
                        .font(.headline)
                    Text("Ingredients:")
                        .font(.subheadline)
                    ForEach(recipe.ingredients, id: \.self) { ingredient in
                        HStack {
                            Text(ingredient)
                                .foregroundColor(recipe.missingIngredients.contains(ingredient) ? .red : .primary)
                            if recipe.missingIngredients.contains(ingredient) {
                                Text("(Missing)")
                                    .foregroundColor(.red)
                                    .italic()
                            }
                        }
                    }
                    Button("View Recipe Details") {
                        // Simulate viewing recipe details
                    }
                    .padding(.top, 5)
                }
            }
            Spacer()
        }
        .navigationTitle("Recipes")
        .padding()
    }
}

struct RecipesView_Previews: PreviewProvider {
    static var previews: some View {
        RecipesView()
    }
}
