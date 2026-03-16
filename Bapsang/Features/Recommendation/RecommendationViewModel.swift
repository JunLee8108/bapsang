//
//  RecommendationViewModel.swift
//  Bapsang
//

import Foundation

@Observable
final class RecommendationViewModel {
    var categories: [RecipeCategory] = RecipeCategory.defaults

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
}
