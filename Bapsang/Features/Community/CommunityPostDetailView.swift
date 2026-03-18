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
    @State private var commentToDelete: UUID?
    @State private var showEditSheet = false
    @FocusState private var isCommentFocused: Bool
    @State private var localLikesCount: Int
    @State private var localIsLiked: Bool = false
    @State private var showFullImage = false

    init(post: CommunityPost, viewModel: CommunityViewModel) {
        self.post = post
        self.viewModel = viewModel
        self._localLikesCount = State(initialValue: post.likesCount)
    }

    private var isOwnPost: Bool {
        authService.currentUserId == post.userId
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 24) {
                    // Recipe Image
                    if let imageUrl = post.imageUrl, let url = URL(string: imageUrl) {
                        CachedAsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                Button {
                                    showFullImage = true
                                } label: {
                                    Color.clear
                                        .frame(height: 200)
                                        .overlay {
                                            image
                                                .resizable()
                                                .scaledToFill()
                                        }
                                        .clipped()
                                        .contentShape(Rectangle())
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                }
                                .buttonStyle(.plain)
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
                        .fullScreenCover(isPresented: $showFullImage) {
                            FullScreenRemoteImageView(url: url, title: post.title)
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
            if let userId = authService.currentUserId {
                ToolbarItem(placement: .topBarTrailing) {
                    BookmarkButton(
                        sourceType: .community,
                        sourceId: post.id,
                        userId: userId
                    )
                }
            }

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
        .alert("Delete this comment?", isPresented: .init(
            get: { commentToDelete != nil },
            set: { if !$0 { commentToDelete = nil } }
        )) {
            Button("Delete", role: .destructive) {
                if let id = commentToDelete {
                    Task { await viewModel.deleteComment(commentId: id, postId: post.id) }
                }
            }
            Button("Cancel", role: .cancel) { commentToDelete = nil }
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
        .sheet(isPresented: $viewModel.showCommentReportSheet) {
            commentReportSheet
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .task {
            await viewModel.fetchComments(postId: post.id)
            if let userId = authService.currentUserId {
                await viewModel.checkIfLiked(postId: post.id, userId: userId)
                localIsLiked = viewModel.likedPostIds.contains(post.id)
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
                Text(viewModel.displayName(for: post.userId))
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
                localIsLiked.toggle()
                localLikesCount += localIsLiked ? 1 : -1
                Task { await viewModel.toggleLike(postId: post.id, userId: userId) }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: localIsLiked ? "heart.fill" : "heart")
                        .font(.system(size: 20))
                        .foregroundStyle(localIsLiked ? .red : .secondary)
                        .animation(.spring(response: 0.3), value: localIsLiked)

                    Text("\(localLikesCount)")
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

    // MARK: - Comments

    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(icon: "bubble.right", title: "Comments (\(viewModel.comments.count))")

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

                Text(viewModel.displayName(for: comment.userId))
                    .font(.system(size: 13, weight: .semibold, design: .rounded))

                Spacer()

                Text(comment.timeAgo)
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)

                if comment.userId == authService.currentUserId {
                    Button {
                        commentToDelete = comment.id
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.tertiary)
                            .frame(width: 36, height: 36)
                            .contentShape(Rectangle())
                    }
                } else {
                    Menu {
                        Button {
                            viewModel.reportingCommentId = comment.id
                            viewModel.showCommentReportSheet = true
                        } label: {
                            Label("Report", systemImage: "exclamationmark.triangle")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.tertiary)
                            .frame(width: 36, height: 36)
                            .contentShape(Rectangle())
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

    // MARK: - Comment Report Sheet

    private var commentReportSheet: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.orange)

                Text("Why are you reporting this comment?")
                    .font(.system(size: 16, weight: .semibold))

                TextEditor(text: $viewModel.commentReportReason)
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
                    Task { await viewModel.reportComment(reporterId: userId) }
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
                .disabled(viewModel.commentReportReason.trimmingCharacters(in: .whitespaces).isEmpty)
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top, 24)
            .navigationTitle("Report Comment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { viewModel.showCommentReportSheet = false }
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

// MARK: - Full Screen Remote Image

private struct FullScreenRemoteImageView: View {
    let url: URL
    let title: String
    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            CachedAsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(
                            MagnifyGesture()
                                .onChanged { value in
                                    scale = lastScale * value.magnification
                                }
                                .onEnded { _ in
                                    lastScale = max(scale, 1.0)
                                    scale = max(scale, 1.0)
                                    if scale == 1.0 {
                                        withAnimation(.spring(response: 0.3)) {
                                            offset = .zero
                                            lastOffset = .zero
                                        }
                                    }
                                }
                                .simultaneously(
                                    with: DragGesture()
                                        .onChanged { value in
                                            if scale > 1.0 {
                                                offset = CGSize(
                                                    width: lastOffset.width + value.translation.width,
                                                    height: lastOffset.height + value.translation.height
                                                )
                                            }
                                        }
                                        .onEnded { _ in
                                            lastOffset = offset
                                        }
                                )
                        )
                        .onTapGesture(count: 2) {
                            withAnimation(.spring(response: 0.3)) {
                                if scale > 1.0 {
                                    scale = 1.0
                                    lastScale = 1.0
                                    offset = .zero
                                    lastOffset = .zero
                                } else {
                                    scale = 2.5
                                    lastScale = 2.5
                                }
                            }
                        }
                case .failure:
                    Image(systemName: "photo")
                        .font(.system(size: 40))
                        .foregroundStyle(.white.opacity(0.5))
                default:
                    ProgressView()
                        .tint(.white)
                }
            }

            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(.white.opacity(0.8))
                            .padding(16)
                    }
                }
                Spacer()

                Text(title)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
                    .padding(.bottom, 40)
            }
        }
    }
}
