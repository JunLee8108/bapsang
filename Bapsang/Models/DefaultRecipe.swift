//
//  DefaultRecipe.swift
//  Bapsang
//

import Foundation

struct DefaultRecipe: Identifiable, Hashable {
    let id: UUID
    let categoryName: String
    let name: String
    let koreanName: String
    let emoji: String
    let difficulty: Difficulty
    let cookingTime: Int // minutes
    let servingSize: Int
    let description: String
    let ingredients: [String]
    let steps: [String]

    enum Difficulty: String, Hashable {
        case easy, medium, hard

        var label: String {
            switch self {
            case .easy:   return "Easy"
            case .medium: return "Medium"
            case .hard:   return "Hard"
            }
        }

        var color: String {
            switch self {
            case .easy:   return "green"
            case .medium: return "orange"
            case .hard:   return "red"
            }
        }
    }
}
