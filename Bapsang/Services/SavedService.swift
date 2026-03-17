//
//  SavedService.swift
//  Bapsang
//

import Foundation
import Supabase

@Observable
@MainActor
final class SavedService {

    // MARK: - Save / Unsave

    func saveItem(userId: UUID, sourceType: SavedSourceType, sourceId: UUID) async throws {
        let payload = SavePayload(userId: userId, sourceType: sourceType.rawValue, sourceId: sourceId)
        try await supabase
            .from("saved_items")
            .insert(payload)
            .execute()
    }

    func unsaveItem(userId: UUID, sourceType: SavedSourceType, sourceId: UUID) async throws {
        try await supabase
            .from("saved_items")
            .delete()
            .eq("user_id", value: userId)
            .eq("source_type", value: sourceType.rawValue)
            .eq("source_id", value: sourceId)
            .execute()
    }

    // MARK: - Fetch

    func fetchSavedItems(userId: UUID, sourceType: SavedSourceType) async throws -> [SavedItem] {
        return try await supabase
            .from("saved_items")
            .select()
            .eq("user_id", value: userId)
            .eq("source_type", value: sourceType.rawValue)
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    func fetchSavedSourceIds(userId: UUID, sourceType: SavedSourceType) async throws -> Set<UUID> {
        let items: [SavedItem] = try await fetchSavedItems(userId: userId, sourceType: sourceType)
        return Set(items.map(\.sourceId))
    }

    // MARK: - Check

    func checkIfSaved(userId: UUID, sourceType: SavedSourceType, sourceId: UUID) async throws -> Bool {
        let result: [SavedItem] = try await supabase
            .from("saved_items")
            .select()
            .eq("user_id", value: userId)
            .eq("source_type", value: sourceType.rawValue)
            .eq("source_id", value: sourceId)
            .execute()
            .value
        return !result.isEmpty
    }

    // MARK: - Fetch Community Posts by IDs

    func fetchCommunityPosts(ids: Set<UUID>) async throws -> [CommunityPost] {
        guard !ids.isEmpty else { return [] }
        return try await supabase
            .from("community_posts")
            .select()
            .in("id", values: ids.map(\.uuidString))
            .eq("is_hidden", value: false)
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
}

// MARK: - Payload

private struct SavePayload: Encodable {
    let userId: UUID
    let sourceType: String
    let sourceId: UUID

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case sourceType = "source_type"
        case sourceId = "source_id"
    }
}
