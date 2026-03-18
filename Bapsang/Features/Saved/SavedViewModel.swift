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
    var isLoading = true
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

    init() {
        NotificationCenter.default.addObserver(
            forName: .savedItemChanged,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let sourceType = notification.userInfo?["sourceType"] as? String else { return }
            Task { @MainActor [weak self] in
                if sourceType == "default" {
                    self?.hasFetchedDefault = false
                } else if sourceType == "community" {
                    self?.hasFetchedCommunity = false
                }
            }
        }
    }

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
        isLoading = true
        defer { isLoading = false }

        do {
            switch selectedTab {
            case .default:
                let ids = try await service.fetchSavedSourceIds(userId: userId, sourceType: .default)
                savedDefaultIds = ids
                savedDefaultRecipes = ids.compactMap { DefaultRecipeData.recipe(for: $0) }
                hasFetchedDefault = true
            case .community:
                let ids = try await service.fetchSavedSourceIds(userId: userId, sourceType: .community)
                savedCommunityIds = ids
                let posts = try await service.fetchCommunityPosts(ids: ids)
                savedCommunityPosts = posts
                // Fetch author names
                let userIds = Set(posts.map(\.userId))
                let newIds = userIds.subtracting(authorNames.keys)
                if !newIds.isEmpty {
                    let names = try await service.fetchDisplayNames(userIds: newIds)
                    authorNames.merge(names) { _, new in new }
                }
                hasFetchedCommunity = true
            }
        } catch {
            errorMessage = "저장된 레시피를 불러올 수 없습니다."
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

    // MARK: - Display Name

    func displayName(for userId: UUID) -> String {
        authorNames[userId] ?? "Chef"
    }
}
