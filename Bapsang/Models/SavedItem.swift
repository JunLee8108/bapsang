//
//  SavedItem.swift
//  Bapsang
//

import Foundation

enum SavedSourceType: String, Codable, CaseIterable {
    case `default` = "default"
    case community = "community"

    var label: String {
        switch self {
        case .default:   return "Recipes"
        case .community: return "Community"
        }
    }
}

struct SavedItem: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let sourceType: String
    let sourceId: UUID
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case sourceType = "source_type"
        case sourceId = "source_id"
        case createdAt = "created_at"
    }
}
