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
            .select()
            .eq("is_hidden", value: false)

        switch sortBy {
        case .latest:
            return try await query.order("created_at", ascending: false).execute().value
        case .popular:
            return try await query.order("likes_count", ascending: false).execute().value
        }
    }

    func fetchPost(id: UUID) async throws -> CommunityPost {
        return try await supabase
            .from("community_posts")
            .select()
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
        let payload = CreatePostPayload(
            userId: userId,
            title: title,
            description: description,
            ingredients: ingredients,
            steps: steps,
            cookingTime: cookingTime,
            difficulty: difficulty,
            servingSize: servingSize,
            imageUrl: imageUrl
        )

        return try await supabase
            .from("community_posts")
            .insert(payload)
            .select()
            .single()
            .execute()
            .value
    }

    func updatePost(
        id: UUID,
        title: String,
        description: String?,
        ingredients: [String],
        steps: [String],
        cookingTime: Int?,
        difficulty: String?,
        servingSize: Int?,
        imageUrl: String?
    ) async throws -> CommunityPost {
        let payload = UpdatePostPayload(
            title: title,
            description: description,
            ingredients: ingredients,
            steps: steps,
            cookingTime: cookingTime,
            difficulty: difficulty,
            servingSize: servingSize,
            imageUrl: imageUrl
        )

        return try await supabase
            .from("community_posts")
            .update(payload)
            .eq("id", value: id)
            .select()
            .single()
            .execute()
            .value
    }

    func deletePost(id: UUID) async throws {
        // Fetch the post first to get imageUrl before deleting
        let posts: [CommunityPost] = try await supabase
            .from("community_posts")
            .select()
            .eq("id", value: id)
            .execute()
            .value

        if let imageUrl = posts.first?.imageUrl {
            try? await deleteImage(urlString: imageUrl)
        }

        try await supabase
            .from("community_posts")
            .delete()
            .eq("id", value: id)
            .execute()
    }

    func deleteImage(urlString: String) async throws {
        let bucket = "community-images"
        // URL format: .../storage/v1/object/public/community-images/{userId}/{file}.jpg
        guard let range = urlString.range(of: "\(bucket)/") else { return }
        let path = String(urlString[range.upperBound...])
        guard !path.isEmpty else { return }
        try await supabase.storage
            .from(bucket)
            .remove(paths: [path])
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
            let payload = LikePayload(postId: postId, userId: userId)
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
            .select()
            .eq("post_id", value: postId)
            .order("created_at", ascending: true)
            .execute()
            .value
    }

    func addComment(postId: UUID, userId: UUID, content: String) async throws -> CommunityComment {
        let payload = CommentPayload(postId: postId, userId: userId, content: content)

        return try await supabase
            .from("community_comments")
            .insert(payload)
            .select()
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
        let payload = ReportPayload(postId: postId, reporterId: reporterId, reason: reason)

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
            let payload = ProfilePayload(id: userId)
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
            .upload(fileName, data: data, options: .init(contentType: "image/jpeg"))

        let publicURL = try supabase.storage
            .from("community-images")
            .getPublicURL(path: fileName)

        return publicURL.absoluteString
    }
}

// MARK: - Sort

enum PostSort: String, CaseIterable {
    case latest = "Latest"
    case popular = "Popular"
}

// MARK: - Payload Types

private struct CreatePostPayload: Encodable {
    let userId: UUID
    let title: String
    let description: String?
    let ingredients: [String]
    let steps: [String]
    let cookingTime: Int?
    let difficulty: String?
    let servingSize: Int?
    let imageUrl: String?

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case title, description, ingredients, steps
        case cookingTime = "cooking_time"
        case difficulty
        case servingSize = "serving_size"
        case imageUrl = "image_url"
    }
}

private struct UpdatePostPayload: Encodable {
    let title: String
    let description: String?
    let ingredients: [String]
    let steps: [String]
    let cookingTime: Int?
    let difficulty: String?
    let servingSize: Int?
    let imageUrl: String?

    enum CodingKeys: String, CodingKey {
        case title, description, ingredients, steps
        case cookingTime = "cooking_time"
        case difficulty
        case servingSize = "serving_size"
        case imageUrl = "image_url"
    }
}

private struct LikePayload: Encodable {
    let postId: UUID
    let userId: UUID

    enum CodingKeys: String, CodingKey {
        case postId = "post_id"
        case userId = "user_id"
    }
}

private struct CommentPayload: Encodable {
    let postId: UUID
    let userId: UUID
    let content: String

    enum CodingKeys: String, CodingKey {
        case postId = "post_id"
        case userId = "user_id"
        case content
    }
}

private struct ReportPayload: Encodable {
    let postId: UUID
    let reporterId: UUID
    let reason: String

    enum CodingKeys: String, CodingKey {
        case postId = "post_id"
        case reporterId = "reporter_id"
        case reason
    }
}

private struct ProfilePayload: Encodable {
    let id: UUID
}

private struct CommunityLike: Codable {
    let id: UUID
}
