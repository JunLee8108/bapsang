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

    nonisolated static let pageSize = 15

    func fetchPosts(
        sortBy: PostSort = .latest,
        cursor: PostCursor? = nil,
        limit: Int = CommunityService.pageSize
    ) async throws -> [CommunityPost] {
        var query = supabase
            .from("community_posts")
            .select()
            .eq("is_hidden", value: false)

        switch sortBy {
        case .latest:
            if let cursor {
                // Posts older than the cursor
                query = query.lt("created_at", value: cursor.createdAt)
            }
            return try await query
                .order("created_at", ascending: false)
                .limit(limit)
                .execute()
                .value

        case .popular:
            if let cursor {
                // Posts with fewer likes, or same likes but older
                query = query.or("likes_count.lt.\(cursor.likesCount),and(likes_count.eq.\(cursor.likesCount),created_at.lt.\(cursor.createdAt))")
            }
            return try await query
                .order("likes_count", ascending: false)
                .order("created_at", ascending: false)
                .limit(limit)
                .execute()
                .value
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

    /// Batch check which posts the user has liked
    func fetchLikedPostIds(postIds: [UUID], userId: UUID) async throws -> Set<UUID> {
        guard !postIds.isEmpty else { return [] }
        let rows: [PostIdOnly] = try await supabase
            .from("community_likes")
            .select("post_id")
            .eq("user_id", value: userId)
            .in("post_id", values: postIds.map(\.uuidString))
            .execute()
            .value
        return Set(rows.map(\.postId))
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
            .eq("is_hidden", value: false)
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

    func reportComment(commentId: UUID, reporterId: UUID, reason: String) async throws {
        let payload = CommentReportPayload(commentId: commentId, reporterId: reporterId, reason: reason)

        try await supabase
            .from("community_comment_reports")
            .insert(payload)
            .execute()
    }

    // MARK: - Profile

    func fetchUserProfile(userId: UUID) async throws -> UserProfile {
        return try await supabase
            .from("users")
            .select("id, display_name, total_likes_received, total_posts, badges, created_at")
            .eq("id", value: userId)
            .single()
            .execute()
            .value
    }

    func fetchDisplayNames(userIds: Set<UUID>) async throws -> [UUID: String] {
        guard !userIds.isEmpty else { return [:] }
        let rows: [UserIdName] = try await supabase
            .from("users")
            .select("id, display_name")
            .in("id", values: userIds.map(\.uuidString))
            .execute()
            .value
        return Dictionary(uniqueKeysWithValues: rows.map { ($0.id, $0.displayName) })
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

private struct CommentReportPayload: Encodable {
    let commentId: UUID
    let reporterId: UUID
    let reason: String

    enum CodingKeys: String, CodingKey {
        case commentId = "comment_id"
        case reporterId = "reporter_id"
        case reason
    }
}

private struct CommunityLike: Codable {
    let id: UUID
}

private struct PostIdOnly: Codable {
    let postId: UUID

    enum CodingKeys: String, CodingKey {
        case postId = "post_id"
    }
}

struct PostCursor {
    let createdAt: String   // ISO8601 string for Supabase filter
    let likesCount: Int

    init(from post: CommunityPost) {
        if let date = post.createdAt {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            self.createdAt = formatter.string(from: date)
        } else {
            self.createdAt = ""
        }
        self.likesCount = post.likesCount
    }
}

struct UserIdName: Codable {
    let id: UUID
    let displayName: String

    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
    }
}
