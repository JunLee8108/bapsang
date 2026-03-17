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

@Observable
@MainActor
final class CommunityViewModel {

    // MARK: - State

    var posts: [CommunityPost] = []
    var sortBy: PostSort = .latest
    var isLoading = false
    var errorMessage: String?

    // Detail view state
    var comments: [CommunityComment] = []
    var isLoadingComments = false
    var commentText = ""
    var likedPostIds: Set<UUID> = []

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

    // Edit post state
    var editingPost: CommunityPost?

    // Report
    var showReportSheet = false
    var reportReason = ""

    private let service = CommunityService()

    // MARK: - Fetch Posts

    func fetchPosts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            posts = try await service.fetchPosts(sortBy: sortBy)
        } catch {
            errorMessage = "게시물을 불러올 수 없습니다."
        }
    }

    func changeSortAndRefresh(_ sort: PostSort) async {
        sortBy = sort
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
            if let index = posts.firstIndex(where: { $0.id == postId }) {
                posts[index].likesCount += isNowLiked ? 1 : -1
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

    // MARK: - Comments

    func fetchComments(postId: UUID) async {
        isLoadingComments = true
        defer { isLoadingComments = false }

        do {
            comments = try await service.fetchComments(postId: postId)
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

            if let index = posts.firstIndex(where: { $0.id == postId }) {
                posts[index].commentsCount -= 1
            }
        } catch {
            errorMessage = "댓글 삭제에 실패했습니다."
        }
    }

    // MARK: - Create Post

    func createPost(userId: UUID) async -> Bool {
        let title = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else {
            errorMessage = "제목을 입력해주세요."
            return false
        }

        let ingredients = newIngredients
            .map { $0.value.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let steps = newSteps
            .map { $0.value.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard !ingredients.isEmpty else {
            errorMessage = "재료를 하나 이상 입력해주세요."
            return false
        }
        guard !steps.isEmpty else {
            errorMessage = "조리 단계를 하나 이상 입력해주세요."
            return false
        }

        isSubmitting = true
        defer { isSubmitting = false }

        do {
            // Ensure profile exists
            try await service.ensureProfile(userId: userId)

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

        let title = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else {
            errorMessage = "제목을 입력해주세요."
            return false
        }

        let ingredients = newIngredients
            .map { $0.value.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let steps = newSteps
            .map { $0.value.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard !ingredients.isEmpty else {
            errorMessage = "재료를 하나 이상 입력해주세요."
            return false
        }
        guard !steps.isEmpty else {
            errorMessage = "조리 단계를 하나 이상 입력해주세요."
            return false
        }

        isSubmitting = true
        defer { isSubmitting = false }

        do {
            // Upload new image if selected, otherwise keep existing
            var imageUrl = editingPost.imageUrl
            if let imageData = newImageData {
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
