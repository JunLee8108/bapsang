//
//  CommunityViewModel.swift
//  Bapsang
//

import Foundation
import Observation

struct IdentifiableField: Identifiable {
    let id = UUID()
    var value: String
}

enum PostValidationError: Equatable {
    case title
    case ingredients
    case steps

    var message: String {
        switch self {
        case .title:       return "Please enter a title."
        case .ingredients: return "Please add at least one ingredient."
        case .steps:       return "Please add at least one step."
        }
    }
}

@Observable
@MainActor
final class CommunityViewModel {

    // MARK: - State

    var posts: [CommunityPost] = []
    var sortBy: PostSort = .latest
    var isLoading = false
    var errorMessage: String?

    // Pagination
    var isFetchingMore = false
    var hasMorePages = true
    private var lastCursor: PostCursor?

    // First-page cache for stale-while-revalidate
    private var cachedFirstPage: [CommunityPost]?
    private var cachedSortBy: PostSort?

    // Detail view state
    var comments: [CommunityComment] = []
    var isLoadingComments = false
    var commentText = ""
    var likedPostIds: Set<UUID> = []
    var likesCountDelta: [UUID: Int] = [:]
    var commentsCountDelta: [UUID: Int] = [:]

    // Author display names cache
    var authorNames: [UUID: String] = [:]
    private var displayNameObserver: Any?

    init() {
        displayNameObserver = NotificationCenter.default.addObserver(
            forName: .displayNameDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.authorNames = [:]
        }
    }

    deinit {
        if let observer = displayNameObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    // Create post state
    var newTitle = ""
    var newDescription = ""
    var newIngredients: [IdentifiableField] = [IdentifiableField(value: "")]
    var newSteps: [IdentifiableField] = [IdentifiableField(value: "")]
    var newCookingTime = 30
    var newDifficulty = "easy"
    var newServingSize = 2
    var newImageData: Data?
    var isSubmitting = false
    var validationError: PostValidationError?

    // Edit post state
    var editingPost: CommunityPost?

    // Report (post)
    var showReportSheet = false
    var reportReason = ""

    // Report (comment)
    var showCommentReportSheet = false
    var commentReportReason = ""
    var reportingCommentId: UUID?

    private let service = CommunityService()

    // MARK: - Fetch Posts

    /// Initial load — shows cache immediately, then refreshes from network.
    func fetchPosts() async {
        // Show cached first page instantly if available for the same sort
        if let cached = cachedFirstPage, cachedSortBy == sortBy, posts.isEmpty {
            posts = cached
        }

        isLoading = posts.isEmpty
        hasMorePages = true
        lastCursor = nil

        do {
            let newPosts = try await service.fetchPosts(sortBy: sortBy)
            posts = newPosts
            hasMorePages = newPosts.count >= CommunityService.pageSize
            lastCursor = newPosts.last.map { PostCursor(from: $0) }

            // Update first-page cache
            cachedFirstPage = newPosts
            cachedSortBy = sortBy

            // Batch fetch display names
            let userIds = Set(newPosts.map(\.userId))
            let newIds = userIds.subtracting(authorNames.keys)
            if !newIds.isEmpty {
                let names = try await service.fetchDisplayNames(userIds: newIds)
                authorNames.merge(names) { _, new in new }
            }
        } catch {
            if posts.isEmpty {
                errorMessage = "게시물을 불러올 수 없습니다."
            }
        }

        isLoading = false
    }

    /// Load next page for infinite scroll.
    func fetchMorePosts() async {
        guard !isFetchingMore, hasMorePages, let cursor = lastCursor else { return }
        isFetchingMore = true
        defer { isFetchingMore = false }

        do {
            let newPosts = try await service.fetchPosts(sortBy: sortBy, cursor: cursor)
            guard !newPosts.isEmpty else {
                hasMorePages = false
                return
            }

            // Deduplicate
            let existingIds = Set(posts.map(\.id))
            let unique = newPosts.filter { !existingIds.contains($0.id) }
            posts.append(contentsOf: unique)

            hasMorePages = newPosts.count >= CommunityService.pageSize
            lastCursor = newPosts.last.map { PostCursor(from: $0) }

            // Batch fetch display names for new authors
            let newUserIds = Set(unique.map(\.userId)).subtracting(authorNames.keys)
            if !newUserIds.isEmpty {
                let names = try await service.fetchDisplayNames(userIds: newUserIds)
                authorNames.merge(names) { _, new in new }
            }
        } catch {
            // Silently fail — user can scroll again to retry
        }
    }

    /// Pull-to-refresh — clears cache and reloads from scratch.
    func refreshPosts() async {
        cachedFirstPage = nil
        cachedSortBy = nil
        likesCountDelta = [:]
        commentsCountDelta = [:]
        authorNames = [:]
        await fetchPosts()
    }

    func changeSortAndRefresh(_ sort: PostSort) async {
        sortBy = sort
        posts = []      // Clear immediately for sort change
        likedPostIds = []
        await fetchPosts()
    }

    // MARK: - Like

    func toggleLike(postId: UUID, userId: UUID) async {
        do {
            let isNowLiked = try await service.toggleLike(postId: postId, userId: userId)

            if isNowLiked {
                likedPostIds.insert(postId)
            } else {
                likedPostIds.remove(postId)
            }

            // Update local count
            let delta = isNowLiked ? 1 : -1
            likesCountDelta[postId, default: 0] += delta
            if let index = posts.firstIndex(where: { $0.id == postId }) {
                posts[index].likesCount += delta
            }
        } catch {
            errorMessage = "좋아요 처리에 실패했습니다."
        }
    }

    func checkIfLiked(postId: UUID, userId: UUID) async {
        do {
            let liked = try await service.checkIfLiked(postId: postId, userId: userId)
            if liked {
                likedPostIds.insert(postId)
            }
        } catch {}
    }

    /// Batch check liked status for a set of posts
    func batchCheckLikedStatus(postIds: [UUID], userId: UUID) async {
        do {
            let liked = try await service.fetchLikedPostIds(postIds: postIds, userId: userId)
            likedPostIds.formUnion(liked)
        } catch {}
    }

    // MARK: - Comments

    func fetchComments(postId: UUID) async {
        isLoadingComments = true
        defer { isLoadingComments = false }

        do {
            comments = try await service.fetchComments(postId: postId)
            let userIds = Set(comments.map(\.userId))
            let newIds = userIds.subtracting(authorNames.keys)
            if !newIds.isEmpty {
                let names = try await service.fetchDisplayNames(userIds: newIds)
                authorNames.merge(names) { _, new in new }
            }
        } catch {
            errorMessage = "댓글을 불러올 수 없습니다."
        }
    }

    func addComment(postId: UUID, userId: UUID) async {
        let text = commentText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        do {
            let comment = try await service.addComment(postId: postId, userId: userId, content: text)
            comments.append(comment)
            commentText = ""

            // Cache current user's display name if missing
            if authorNames[userId] == nil {
                let names = try await service.fetchDisplayNames(userIds: [userId])
                authorNames.merge(names) { _, new in new }
            }

            commentsCountDelta[postId, default: 0] += 1
            if let index = posts.firstIndex(where: { $0.id == postId }) {
                posts[index].commentsCount += 1
            }
        } catch {
            errorMessage = "댓글 작성에 실패했습니다."
        }
    }

    func deleteComment(commentId: UUID, postId: UUID) async {
        do {
            try await service.deleteComment(id: commentId)
            comments.removeAll { $0.id == commentId }

            commentsCountDelta[postId, default: 0] -= 1
            if let index = posts.firstIndex(where: { $0.id == postId }) {
                posts[index].commentsCount -= 1
            }
        } catch {
            errorMessage = "댓글 삭제에 실패했습니다."
        }
    }

    // MARK: - Create Post

    func createPost(userId: UUID) async -> Bool {
        validationError = nil
        let title = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else {
            validationError = .title
            return false
        }

        let ingredients = newIngredients
            .map { $0.value.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let steps = newSteps
            .map { $0.value.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard !ingredients.isEmpty else {
            validationError = .ingredients
            return false
        }
        guard !steps.isEmpty else {
            validationError = .steps
            return false
        }

        isSubmitting = true
        defer { isSubmitting = false }

        do {
            // Upload image if selected
            var imageUrl: String?
            if let imageData = newImageData {
                imageUrl = try await service.uploadImage(data: imageData, userId: userId)
            }

            let post = try await service.createPost(
                userId: userId,
                title: title,
                description: newDescription.isEmpty ? nil : newDescription,
                ingredients: ingredients,
                steps: steps,
                cookingTime: newCookingTime,
                difficulty: newDifficulty,
                servingSize: newServingSize,
                imageUrl: imageUrl
            )

            posts.insert(post, at: 0)

            // Cache current user's display name if missing
            if authorNames[userId] == nil {
                let names = try await service.fetchDisplayNames(userIds: [userId])
                authorNames.merge(names) { _, new in new }
            }

            resetCreateForm()
            return true
        } catch {
            errorMessage = "게시물 작성에 실패했습니다."
            return false
        }
    }

    func populateFormForEdit(_ post: CommunityPost) {
        editingPost = post
        newTitle = post.title
        newDescription = post.description ?? ""
        newIngredients = post.ingredients.isEmpty ? [IdentifiableField(value: "")] : post.ingredients.map { IdentifiableField(value: $0) }
        newSteps = post.steps.isEmpty ? [IdentifiableField(value: "")] : post.steps.map { IdentifiableField(value: $0) }
        newCookingTime = post.cookingTime ?? 30
        newDifficulty = post.difficulty ?? "easy"
        newServingSize = post.servingSize ?? 2
        newImageData = nil
    }

    func updatePost(userId: UUID) async -> Bool {
        guard let editingPost else { return false }

        validationError = nil
        let title = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else {
            validationError = .title
            return false
        }

        let ingredients = newIngredients
            .map { $0.value.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let steps = newSteps
            .map { $0.value.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard !ingredients.isEmpty else {
            validationError = .ingredients
            return false
        }
        guard !steps.isEmpty else {
            validationError = .steps
            return false
        }

        isSubmitting = true
        defer { isSubmitting = false }

        do {
            // Upload new image if selected, otherwise keep existing
            var imageUrl = editingPost.imageUrl
            if let imageData = newImageData {
                // Delete the old image from storage before uploading the new one
                if let oldUrl = editingPost.imageUrl {
                    try? await service.deleteImage(urlString: oldUrl)
                }
                imageUrl = try await service.uploadImage(data: imageData, userId: userId)
            }

            let updated = try await service.updatePost(
                id: editingPost.id,
                title: title,
                description: newDescription.isEmpty ? nil : newDescription,
                ingredients: ingredients,
                steps: steps,
                cookingTime: newCookingTime,
                difficulty: newDifficulty,
                servingSize: newServingSize,
                imageUrl: imageUrl
            )

            if let index = posts.firstIndex(where: { $0.id == editingPost.id }) {
                posts[index] = updated
            }
            self.editingPost = nil
            resetCreateForm()
            return true
        } catch {
            errorMessage = "게시물 수정에 실패했습니다."
            return false
        }
    }

    func deletePost(id: UUID) async {
        do {
            try await service.deletePost(id: id)
            posts.removeAll { $0.id == id }
        } catch {
            errorMessage = "게시물 삭제에 실패했습니다."
        }
    }

    // MARK: - Report

    func reportPost(postId: UUID, reporterId: UUID) async {
        let reason = reportReason.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !reason.isEmpty else { return }

        do {
            try await service.reportPost(postId: postId, reporterId: reporterId, reason: reason)
            reportReason = ""
            showReportSheet = false
        } catch {
            errorMessage = "이미 신고한 게시물입니다."
        }
    }

    func reportComment(reporterId: UUID) async {
        let reason = commentReportReason.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !reason.isEmpty, let commentId = reportingCommentId else { return }

        do {
            try await service.reportComment(commentId: commentId, reporterId: reporterId, reason: reason)
            commentReportReason = ""
            reportingCommentId = nil
            showCommentReportSheet = false
        } catch {
            errorMessage = "이미 신고한 댓글입니다."
        }
    }

    // MARK: - Display Name

    func displayName(for userId: UUID) -> String {
        authorNames[userId] ?? "Chef"
    }

    // MARK: - Helpers

    func resetCreateForm() {
        newTitle = ""
        newDescription = ""
        newIngredients = [IdentifiableField(value: "")]
        newSteps = [IdentifiableField(value: "")]
        newCookingTime = 30
        newDifficulty = "easy"
        newServingSize = 2
        newImageData = nil
        validationError = nil
    }

    func addIngredientField() {
        newIngredients.append(IdentifiableField(value: ""))
    }

    func removeIngredientField(id: UUID) {
        guard newIngredients.count > 1 else { return }
        newIngredients.removeAll { $0.id == id }
    }

    func addStepField() {
        newSteps.append(IdentifiableField(value: ""))
    }

    func removeStepField(id: UUID) {
        guard newSteps.count > 1 else { return }
        newSteps.removeAll { $0.id == id }
    }
}
