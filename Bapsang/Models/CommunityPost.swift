//
//  CommunityPost.swift
//  Bapsang
//

import Foundation

struct CommunityPost: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let title: String
    let description: String?
    let ingredients: [String]
    let steps: [String]
    let cookingTime: Int?
    let difficulty: String?
    let servingSize: Int?
    let imageUrl: String?
    var likesCount: Int
    var commentsCount: Int
    let isHidden: Bool
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case title
        case description
        case ingredients
        case steps
        case cookingTime = "cooking_time"
        case difficulty
        case servingSize = "serving_size"
        case imageUrl = "image_url"
        case likesCount = "likes_count"
        case commentsCount = "comments_count"
        case isHidden = "is_hidden"
        case createdAt = "created_at"
    }

    var difficultyLabel: String {
        switch difficulty {
        case "easy":   return "Easy"
        case "medium": return "Medium"
        case "hard":   return "Hard"
        default:       return "Easy"
        }
    }

    var timeAgo: String {
        guard let createdAt else { return "" }
        let interval = Date().timeIntervalSince(createdAt)
        let minutes = Int(interval / 60)
        if minutes < 1 { return "Just now" }
        if minutes < 60 { return "\(minutes)m ago" }
        let hours = minutes / 60
        if hours < 24 { return "\(hours)h ago" }
        let days = hours / 24
        if days < 30 { return "\(days)d ago" }
        let months = days / 30
        return "\(months)mo ago"
    }
}
