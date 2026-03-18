//
//  SavedViewModel.swift
//  Bapsang
//

import Foundation
import Observation

extension Notification.Name {
    static let savedItemChanged = Notification.Name("savedItemChanged")
}

@Observable
@MainActor
final class SavedViewModel {

    // MARK: - State

    var selectedTab: SavedSourceType = .default
    var isLoadingDefault = true
    var isLoadingCommunity = true
    var errorMessage: String?

    // Default recipes
    var savedDefaultRecipes: [DefaultRecipe] = []

    // Community posts
    var savedCommunityPosts: [CommunityPost] = []
    var authorNames: [UUID: String] = [:]

    // Saved IDs for quick lookup (used by bookmark buttons)
    var savedDefaultIds: Set<UUID> = []
    var savedCommunityIds: Set<UUID> = []

    // Cache flags — only re-fetch when stale
    private var hasFetchedDefault = false
    private var hasFetchedCommunity = false

    private let service = SavedService()

    // MARK: - Fetch

    func fetchSavedIfNeeded(userId: UUID) async {
        switch selectedTab {
        case .default where hasFetchedDefault:
            return
        case .community where hasFetchedCommunity:
            return
        default:
            await fetchSaved(userId: userId)
        }
    }

    func fetchSaved(userId: UUID) async {
        switch selectedTab {
        case .default:
            isLoadingDefault = true
            defer { isLoadingDefault = false }
            do {
                let ids = try await service.fetchSavedSourceIds(userId: userId, sourceType: .default)
                savedDefaultIds = ids
                savedDefaultRecipes = ids.compactMap { DefaultRecipeData.recipe(for: $0) }
                hasFetchedDefault = true
            } catch {
                errorMessage = "저장된 레시피를 불러올 수 없습니다."
            }
        case .community:
            isLoadingCommunity = true
            defer { isLoadingCommunity = false }
            do {
                let ids = try await service.fetchSavedSourceIds(userId: userId, sourceType: .community)
                savedCommunityIds = ids
                let posts = try await service.fetchCommunityPosts(ids: ids)
                savedCommunityPosts = posts
                authorNames = [:]
                let userIds = Set(posts.map(\.userId))
                if !userIds.isEmpty {
                    let names = try await service.fetchDisplayNames(userIds: userIds)
                    authorNames = names
                }
                hasFetchedCommunity = true
            } catch {
                errorMessage = "저장된 레시피를 불러올 수 없습니다."
            }
        }
    }

    // MARK: - Toggle Save

    func toggleSave(userId: UUID, sourceType: SavedSourceType, sourceId: UUID) async {
        do {
            let isSaved = isSaved(sourceType: sourceType, sourceId: sourceId)

            if isSaved {
                try await service.unsaveItem(userId: userId, sourceType: sourceType, sourceId: sourceId)
                switch sourceType {
                case .default:
                    savedDefaultIds.remove(sourceId)
                    savedDefaultRecipes.removeAll { $0.id == sourceId }
                case .community:
                    savedCommunityIds.remove(sourceId)
                    savedCommunityPosts.removeAll { $0.id == sourceId }
                }
            } else {
                try await service.saveItem(userId: userId, sourceType: sourceType, sourceId: sourceId)
                switch sourceType {
                case .default:
                    savedDefaultIds.insert(sourceId)
                    if let recipe = DefaultRecipeData.recipe(for: sourceId) {
                        savedDefaultRecipes.insert(recipe, at: 0)
                    }
                case .community:
                    savedCommunityIds.insert(sourceId)
                }
            }
        } catch {
            errorMessage = "저장 처리에 실패했습니다."
        }
    }

    // MARK: - Check

    func isSaved(sourceType: SavedSourceType, sourceId: UUID) -> Bool {
        switch sourceType {
        case .default:   return savedDefaultIds.contains(sourceId)
        case .community: return savedCommunityIds.contains(sourceId)
        }
    }

    // MARK: - Load All Saved IDs (for bookmark buttons across the app)

    func loadSavedIds(userId: UUID) async {
        do {
            savedDefaultIds = try await service.fetchSavedSourceIds(userId: userId, sourceType: .default)
            savedCommunityIds = try await service.fetchSavedSourceIds(userId: userId, sourceType: .community)
        } catch {}
    }

    // MARK: - Sync Likes

    func applyLikeDeltas(from communityVM: CommunityViewModel) {
        for i in savedCommunityPosts.indices {
            let postId = savedCommunityPosts[i].id
            if let delta = communityVM.likesCountDelta[postId] {
                savedCommunityPosts[i].likesCount += delta
            }
        }
        communityVM.likesCountDelta.removeAll()
    }

    func applyCommentDeltas(from communityVM: CommunityViewModel) {
        for i in savedCommunityPosts.indices {
            let postId = savedCommunityPosts[i].id
            if let delta = communityVM.commentsCountDelta[postId] {
                savedCommunityPosts[i].commentsCount += delta
            }
        }
        communityVM.commentsCountDelta.removeAll()
    }

    // MARK: - Display Name

    func displayName(for userId: UUID) -> String {
        authorNames[userId] ?? "Chef"
    }

    // MARK: - Notification Observation

    /// Observe saved item changes via async sequence.
    /// Call from View's `.task` — automatically cancelled when the view disappears.
    func observeSavedItemChanges() async {
        for await notification in NotificationCenter.default.notifications(named: .savedItemChanged) {
            guard let sourceType = notification.userInfo?["sourceType"] as? String,
                  let sourceId = notification.userInfo?["sourceId"] as? UUID,
                  let isSaved = notification.userInfo?["isSaved"] as? Bool
            else { continue }

            if isSaved {
                if sourceType == "default" {
                    hasFetchedDefault = false
                } else if sourceType == "community" {
                    hasFetchedCommunity = false
                }
            } else {
                if sourceType == "default" {
                    savedDefaultIds.remove(sourceId)
                    savedDefaultRecipes.removeAll { $0.id == sourceId }
                } else if sourceType == "community" {
                    savedCommunityIds.remove(sourceId)
                    savedCommunityPosts.removeAll { $0.id == sourceId }
                }
            }
        }
    }

    /// Observe display name changes via async sequence.
    /// Call from View's `.task` — automatically cancelled when the view disappears.
    func observeDisplayNameChanges() async {
        for await _ in NotificationCenter.default.notifications(named: .displayNameDidChange) {
            authorNames = [:]
            // Re-fetch display names for currently visible community posts
            let userIds = Set(savedCommunityPosts.map(\.userId))
            if !userIds.isEmpty {
                let names = try? await service.fetchDisplayNames(userIds: userIds)
                if let names { authorNames.merge(names) { _, new in new } }
            }
        }
    }
}
