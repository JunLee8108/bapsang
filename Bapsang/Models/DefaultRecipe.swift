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
    let imageName: String
    let difficulty: Difficulty
    let cookingTime: Int // minutes
    let servingSize: Int
    let description: String
    let ingredients: [String]
    let steps: [String]

    /// Creates a DefaultRecipe with a stable UUID derived from the recipe name,
    /// so the ID persists across app launches (needed for saved recipes).
    init(
        id: UUID = UUID(),
        categoryName: String,
        name: String,
        koreanName: String,
        emoji: String,
        imageName: String,
        difficulty: Difficulty,
        cookingTime: Int,
        servingSize: Int,
        description: String,
        ingredients: [String],
        steps: [String]
    ) {
        self.id = Self.stableUUID(for: name)
        self.categoryName = categoryName
        self.name = name
        self.koreanName = koreanName
        self.emoji = emoji
        self.imageName = imageName
        self.difficulty = difficulty
        self.cookingTime = cookingTime
        self.servingSize = servingSize
        self.description = description
        self.ingredients = ingredients
        self.steps = steps
    }

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

    /// Generates a deterministic UUID from a recipe name so IDs are stable across launches.
    private static func stableUUID(for name: String) -> UUID {
        let prefix = "bapsang.default."
        let input = Array((prefix + name).utf8)
        var bytes = [UInt8](repeating: 0, count: 16)
        for (i, byte) in input.enumerated() {
            bytes[i % 16] &+= byte &* UInt8(truncatingIfNeeded: (i / 16) + 1)
        }
        // Set UUID version 4 and variant bits for valid UUID format
        bytes[6] = (bytes[6] & 0x0F) | 0x40
        bytes[8] = (bytes[8] & 0x3F) | 0x80
        return UUID(uuid: (
            bytes[0], bytes[1], bytes[2], bytes[3],
            bytes[4], bytes[5], bytes[6], bytes[7],
            bytes[8], bytes[9], bytes[10], bytes[11],
            bytes[12], bytes[13], bytes[14], bytes[15]
        ))
    }
}
