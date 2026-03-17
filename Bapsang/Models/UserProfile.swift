//
//  UserProfile.swift
//  Bapsang
//

import Foundation

struct UserProfile: Codable, Identifiable {
    let id: UUID
    var displayName: String
    var totalLikesReceived: Int
    var totalPosts: Int
    var badges: [Badge]
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case totalLikesReceived = "total_likes_received"
        case totalPosts = "total_posts"
        case badges
        case createdAt = "created_at"
    }

    var topBadge: Badge? {
        // Priority: master > star > popular > prolific > first_post
        let priority: [Badge] = [.master, .star, .popular, .prolific, .first_post]
        return priority.first { badges.contains($0) }
    }
}
