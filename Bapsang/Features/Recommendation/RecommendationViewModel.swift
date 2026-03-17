//
//  RecommendationViewModel.swift
//  Bapsang
//

import Foundation

@Observable
final class RecommendationViewModel {
    var categories: [RecipeCategory] = RecipeCategory.defaults
    var selectedCategory: RecipeCategory?
    var showCategorySheet = false

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Good morning!"
        case 12..<17: return "Good afternoon!"
        default:      return "Good evening!"
        }
    }

    var subtitle: String {
        "What shall we cook today?"
    }

    var recipesForSelectedCategory: [DefaultRecipe] {
        guard let category = selectedCategory else { return [] }
        return DefaultRecipeData.recipes(for: category.name)
    }

    func selectCategory(_ category: RecipeCategory) {
        selectedCategory = category
        showCategorySheet = true
    }
}
