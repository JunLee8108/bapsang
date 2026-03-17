//
//  CommunityPostDetailView.swift
//  Bapsang
//

import SwiftUI

struct CommunityPostDetailView: View {
    let post: CommunityPost
    @Bindable var viewModel: CommunityViewModel
    @Environment(AuthService.self) private var authService
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirm = false
    @State private var showEditSheet = false
    @FocusState private var isCommentFocused: Bool

    private var isOwnPost: Bool {
        authService.currentUserId == post.userId
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 24) {
                    // Recipe Image
                    if let imageUrl = post.imageUrl, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 200)
                                    .clipped()
                                    .contentShape(Rectangle())
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            case .failure:
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.gray.opacity(0.15))
                                    .frame(height: 260)
                                    .overlay {
                                        Image(systemName: "photo")
                                            .font(.system(size: 40))
                                            .foregroundStyle(.tertiary)
                                    }
                            default:
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.gray.opacity(0.1))
                                    .frame(height: 260)
                                    .overlay { ProgressView() }
                            }
                        }
                    }

                    authorSection
                    titleSection
                    metaBar

                    if let description = post.description, !description.isEmpty {
                        descriptionSection(description)
                    }

                    ingredientsSection
                    stepsSection
                    likesSection
                    commentsSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 100)
            }

            commentInputBar
        }
        .navigationTitle("Recipe")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    if isOwnPost {
                        Button {
                            viewModel.populateFormForEdit(post)
                            showEditSheet = true
                        } label: {
                            Label("Edit Post", systemImage: "pencil")
                        }

                        Button(role: .destructive) {
                            showDeleteConfirm = true
                        } label: {
                            Label("Delete Post", systemImage: "trash")
                        }
                    } else {
                        Button {
                            viewModel.showReportSheet = true
                        } label: {
                            Label("Report", systemImage: "exclamationmark.triangle")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .alert("Delete this post?", isPresented: $showDeleteConfirm) {
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel.deletePost(id: post.id)
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
        .sheet(isPresented: $showEditSheet) {
            CommunityCreatePostView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showReportSheet) {
            reportSheet
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .task {
            await viewModel.fetchComments(postId: post.id)
            if let userId = authService.currentUserId {
                await viewModel.checkIfLiked(postId: post.id, userId: userId)
            }
        }
    }

    // MARK: - Author

    private var authorSection: some View {
        HStack(spacing: 10) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 36))
                .foregroundStyle(.orange.opacity(0.7))

            VStack(alignment: .leading, spacing: 2) {
                Text("Chef")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))

                Text(post.timeAgo)
                    .font(.system(size: 12))
                    .foregroundStyle(.tertiary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }

    // MARK: - Title

    private var titleSection: some View {
        Text(post.title)
            .font(.system(size: 24, weight: .bold, design: .rounded))
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Meta Bar

    private var metaBar: some View {
        HStack(spacing: 0) {
            if let time = post.cookingTime {
                metaItem(icon: "clock", label: "\(time) min")
            }
            if post.cookingTime != nil && post.difficulty != nil {
                Divider().frame(height: 28)
            }
            if post.difficulty != nil {
                metaItem(icon: "chart.bar", label: post.difficultyLabel)
            }
            if (post.cookingTime != nil || post.difficulty != nil) && post.servingSize != nil {
                Divider().frame(height: 28)
            }
            if let serving = post.servingSize {
                metaItem(icon: "person.2", label: "\(serving) servings")
            }
        }
        .padding(.vertical, 14)
        .background {
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
        }
    }

    private func metaItem(icon: String, label: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(.orange)
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Description

    private func descriptionSection(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader(icon: "text.alignleft", title: "Description")
            Text(text)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Ingredients

    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(icon: "basket", title: "Ingredients")

            VStack(spacing: 0) {
                ForEach(Array(post.ingredients.enumerated()), id: \.offset) { index, ingredient in
                    HStack(spacing: 10) {
                        Circle()
                            .fill(.orange.opacity(0.7))
                            .frame(width: 6, height: 6)

                        Text(ingredient)
                            .font(.system(size: 14))
                            .foregroundStyle(.primary)

                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)

                    if index < post.ingredients.count - 1 {
                        Divider().padding(.leading, 32)
                    }
                }
            }
            .background {
                RoundedRectangle(cornerRadius: 14)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
            }
        }
    }

    // MARK: - Steps

    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(icon: "list.number", title: "How to Cook")

            VStack(spacing: 12) {
                ForEach(Array(post.steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 14) {
                        Text("\(index + 1)")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(width: 28, height: 28)
                            .background(
                                Circle().fill(
                                    LinearGradient(
                                        colors: [Color(red: 0.9, green: 0.4, blue: 0.1), .orange],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            )

                        Text(step)
                            .font(.system(size: 14))
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
                    }
                }
            }
        }
    }

    // MARK: - Likes

    private var likesSection: some View {
        HStack(spacing: 20) {
            Button {
                guard let userId = authService.currentUserId else { return }
                Task { await viewModel.toggleLike(postId: post.id, userId: userId) }
            } label: {
                let isLiked = viewModel.likedPostIds.contains(post.id)
                HStack(spacing: 8) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .font(.system(size: 20))
                        .foregroundStyle(isLiked ? .red : .secondary)
                        .animation(.spring(response: 0.3), value: isLiked)

                    Text("\(currentLikesCount)")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.primary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
                }
            }
            .buttonStyle(.plain)

            Spacer()
        }
    }

    private var currentLikesCount: Int {
        viewModel.posts.first(where: { $0.id == post.id })?.likesCount ?? post.likesCount
    }

    // MARK: - Comments

    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            let count = viewModel.posts.first(where: { $0.id == post.id })?.commentsCount ?? post.commentsCount
            sectionHeader(icon: "bubble.right", title: "Comments (\(count))")

            if viewModel.isLoadingComments {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if viewModel.comments.isEmpty {
                Text("No comments yet. Be the first!")
                    .font(.system(size: 13))
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                ForEach(viewModel.comments) { comment in
                    commentRow(comment)
                }
            }
        }
    }

    private func commentRow(_ comment: CommunityComment) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "person.circle")
                    .font(.system(size: 16))
                    .foregroundStyle(.orange.opacity(0.6))

                Text("Chef")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))

                Spacer()

                Text(comment.timeAgo)
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)

                if comment.userId == authService.currentUserId {
                    Button {
                        Task { await viewModel.deleteComment(commentId: comment.id, postId: post.id) }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(.tertiary)
                    }
                }
            }

            Text(comment.content)
                .font(.system(size: 13))
                .foregroundStyle(.primary)
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        }
    }

    // MARK: - Comment Input

    private var commentInputBar: some View {
        HStack(spacing: 10) {
            TextField("Write a comment...", text: $viewModel.commentText)
                .font(.system(size: 14))
                .textFieldStyle(.plain)
                .focused($isCommentFocused)

            Button {
                guard let userId = authService.currentUserId else { return }
                Task {
                    await viewModel.addComment(postId: post.id, userId: userId)
                    isCommentFocused = false
                }
            } label: {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(viewModel.commentText.trimmingCharacters(in: .whitespaces).isEmpty ? .gray : .orange)
            }
            .disabled(viewModel.commentText.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundStyle(Color(.systemGray4)),
            alignment: .top
        )
    }

    // MARK: - Report Sheet

    private var reportSheet: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.orange)

                Text("Why are you reporting this post?")
                    .font(.system(size: 16, weight: .semibold))

                TextEditor(text: $viewModel.reportReason)
                    .font(.system(size: 14))
                    .frame(height: 120)
                    .padding(8)
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray4), lineWidth: 0.5)
                    }
                    .padding(.horizontal)

                Button {
                    guard let userId = authService.currentUserId else { return }
                    Task { await viewModel.reportPost(postId: post.id, reporterId: userId) }
                } label: {
                    Text("Submit Report")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(.orange)
                        )
                }
                .disabled(viewModel.reportReason.trimmingCharacters(in: .whitespaces).isEmpty)
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top, 24)
            .navigationTitle("Report Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { viewModel.showReportSheet = false }
                }
            }
        }
    }

    // MARK: - Helpers

    private func sectionHeader(icon: String, title: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundStyle(.orange)

            Text(title)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
        }
    }
}
