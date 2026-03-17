//
//  CommunityService.swift
//  Bapsang
//

import Foundation
import Supabase

@Observable
@MainActor
final class CommunityService {

    // MARK: - Posts

    func fetchPosts(sortBy: PostSort = .latest) async throws -> [CommunityPost] {
        let query = supabase
            .from("community_posts")
            .select("*, user_profiles(*)")
            .eq("is_hidden", value: false)

        let orderedQuery: PostgrestFilterBuilder
        switch sortBy {
        case .latest:
            orderedQuery = query.order("created_at", ascending: false)
        case .popular:
            orderedQuery = query.order("likes_count", ascending: false)
        }

        return try await orderedQuery.execute().value
    }

    func fetchPost(id: UUID) async throws -> CommunityPost {
        return try await supabase
            .from("community_posts")
            .select("*, user_profiles(*)")
            .eq("id", value: id)
            .single()
            .execute()
            .value
    }

    func createPost(
        userId: UUID,
        title: String,
        description: String?,
        ingredients: [String],
        steps: [String],
        cookingTime: Int?,
        difficulty: String?,
        servingSize: Int?,
        imageUrl: String?
    ) async throws -> CommunityPost {
        let payload: [String: AnyJSON] = [
            "user_id": .string(userId.uuidString),
            "title": .string(title),
            "description": description.map { .string($0) } ?? .null,
            "ingredients": .array(ingredients.map { .string($0) }),
            "steps": .array(steps.map { .string($0) }),
            "cooking_time": cookingTime.map { .integer($0) } ?? .null,
            "difficulty": difficulty.map { .string($0) } ?? .null,
            "serving_size": servingSize.map { .integer($0) } ?? .null,
            "image_url": imageUrl.map { .string($0) } ?? .null,
        ]

        return try await supabase
            .from("community_posts")
            .insert(payload)
            .select("*, user_profiles(*)")
            .single()
            .execute()
            .value
    }

    func deletePost(id: UUID) async throws {
        try await supabase
            .from("community_posts")
            .delete()
            .eq("id", value: id)
            .execute()
    }

    // MARK: - Likes

    func checkIfLiked(postId: UUID, userId: UUID) async throws -> Bool {
        let result: [CommunityLike] = try await supabase
            .from("community_likes")
            .select()
            .eq("post_id", value: postId)
            .eq("user_id", value: userId)
            .execute()
            .value
        return !result.isEmpty
    }

    func toggleLike(postId: UUID, userId: UUID) async throws -> Bool {
        let isLiked = try await checkIfLiked(postId: postId, userId: userId)

        if isLiked {
            try await supabase
                .from("community_likes")
                .delete()
                .eq("post_id", value: postId)
                .eq("user_id", value: userId)
                .execute()
            return false
        } else {
            let payload: [String: AnyJSON] = [
                "post_id": .string(postId.uuidString),
                "user_id": .string(userId.uuidString),
            ]
            try await supabase
                .from("community_likes")
                .insert(payload)
                .execute()
            return true
        }
    }

    // MARK: - Comments

    func fetchComments(postId: UUID) async throws -> [CommunityComment] {
        return try await supabase
            .from("community_comments")
            .select("*, user_profiles(*)")
            .eq("post_id", value: postId)
            .order("created_at", ascending: true)
            .execute()
            .value
    }

    func addComment(postId: UUID, userId: UUID, content: String) async throws -> CommunityComment {
        let payload: [String: AnyJSON] = [
            "post_id": .string(postId.uuidString),
            "user_id": .string(userId.uuidString),
            "content": .string(content),
        ]

        return try await supabase
            .from("community_comments")
            .insert(payload)
            .select("*, user_profiles(*)")
            .single()
            .execute()
            .value
    }

    func deleteComment(id: UUID) async throws {
        try await supabase
            .from("community_comments")
            .delete()
            .eq("id", value: id)
            .execute()
    }

    // MARK: - Reports

    func reportPost(postId: UUID, reporterId: UUID, reason: String) async throws {
        let payload: [String: AnyJSON] = [
            "post_id": .string(postId.uuidString),
            "reporter_id": .string(reporterId.uuidString),
            "reason": .string(reason),
        ]

        try await supabase
            .from("community_reports")
            .insert(payload)
            .execute()
    }

    // MARK: - Profile

    func fetchUserProfile(userId: UUID) async throws -> UserProfile {
        return try await supabase
            .from("user_profiles")
            .select()
            .eq("id", value: userId)
            .single()
            .execute()
            .value
    }

    func ensureProfile(userId: UUID) async throws {
        let existing: [UserProfile] = try await supabase
            .from("user_profiles")
            .select()
            .eq("id", value: userId)
            .execute()
            .value

        if existing.isEmpty {
            let payload: [String: AnyJSON] = [
                "id": .string(userId.uuidString),
            ]
            try await supabase
                .from("user_profiles")
                .insert(payload)
                .execute()
        }
    }

    // MARK: - Image Upload

    func uploadImage(data: Data, userId: UUID) async throws -> String {
        let fileName = "\(userId.uuidString)/\(UUID().uuidString).jpg"

        try await supabase.storage
            .from("community-images")
            .upload(
                path: fileName,
                file: data,
                options: .init(contentType: "image/jpeg")
            )

        let publicURL = try supabase.storage
            .from("community-images")
            .getPublicURL(path: fileName)

        return publicURL.absoluteString
    }
}

// MARK: - Supporting Types

enum PostSort: String, CaseIterable {
    case latest = "Latest"
    case popular = "Popular"
}

private struct CommunityLike: Codable {
    let id: UUID
}
