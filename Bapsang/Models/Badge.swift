//
//  Badge.swift
//  Bapsang
//

import Foundation

enum Badge: String, Codable, CaseIterable, Identifiable {
    case first_post  // 🌱 새싹 요리사
    case prolific    // 📝 다작 요리사
    case popular     // 🔥 인기 요리사
    case star        // ⭐ 스타 요리사
    case master      // 👑 마스터 셰프

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .first_post: return "🌱"
        case .prolific:   return "📝"
        case .popular:    return "🔥"
        case .star:       return "⭐"
        case .master:     return "👑"
        }
    }

    var label: String {
        switch self {
        case .first_post: return "새싹 요리사"
        case .prolific:   return "다작 요리사"
        case .popular:    return "인기 요리사"
        case .star:       return "스타 요리사"
        case .master:     return "마스터 셰프"
        }
    }

    var requirement: String {
        switch self {
        case .first_post: return "첫 게시물 작성"
        case .prolific:   return "게시물 10개 달성"
        case .popular:    return "좋아요 10개 달성"
        case .star:       return "좋아요 50개 달성"
        case .master:     return "좋아요 100개 달성"
        }
    }
}
