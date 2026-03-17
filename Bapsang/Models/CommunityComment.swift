//
//  CommunityComment.swift
//  Bapsang
//

import Foundation

struct CommunityComment: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let postId: UUID
    let content: String
    let createdAt: Date?

    // Joined data
    var userProfile: UserProfile?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case postId = "post_id"
        case content
        case createdAt = "created_at"
        case userProfile = "user_profiles"
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
        return "\(days)d ago"
    }
}
