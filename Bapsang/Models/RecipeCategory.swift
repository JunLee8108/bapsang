//
//  RecipeCategory.swift
//  Bapsang
//

import Foundation

struct RecipeCategory: Identifiable, Hashable {
    let id: UUID
    let name: String
    let icon: String
    let description: String
    let sortOrder: Int

    static let defaults: [RecipeCategory] = [
        RecipeCategory(id: UUID(), name: "Soup/Stew",   icon: "🍲", description: "Warm and comforting Korean soups and stews", sortOrder: 1),
        RecipeCategory(id: UUID(), name: "Stir-fry",    icon: "🥘", description: "Quick and flavorful stir-fried dishes",     sortOrder: 2),
        RecipeCategory(id: UUID(), name: "Rice",        icon: "🍚", description: "Hearty rice-based Korean meals",            sortOrder: 3),
        RecipeCategory(id: UUID(), name: "Noodles",     icon: "🍜", description: "Delicious Korean noodle dishes",            sortOrder: 4),
        RecipeCategory(id: UUID(), name: "Side Dishes", icon: "🥗", description: "Traditional Korean banchan",                sortOrder: 5),
        RecipeCategory(id: UUID(), name: "One-Plate",   icon: "🍳", description: "Simple all-in-one plate meals",             sortOrder: 6),
    ]
}
