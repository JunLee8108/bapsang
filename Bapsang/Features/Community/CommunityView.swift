//
//  CommunityView.swift
//  Bapsang
//

import SwiftUI

struct CommunityView: View {
    @Environment(AuthService.self) private var authService
    @State private var viewModel = CommunityViewModel()
    @State private var showCreatePost = false

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient

                ScrollView {
                    VStack(spacing: 16) {
                        headerSection
                        sortPicker
                        postsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 100)
                }
                .refreshable {
                    await viewModel.refreshPosts()
                    if let userId = authService.currentUserId {
                        let postIds = viewModel.posts.map(\.id)
                        await viewModel.batchCheckLikedStatus(postIds: postIds, userId: userId)
                    }
                }

                // FAB
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            showCreatePost = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 56, height: 56)
                                .background(
                                    Circle().fill(
                                        LinearGradient(
                                            colors: [Color(red: 0.9, green: 0.4, blue: 0.1), .orange],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: .orange.opacity(0.4), radius: 12, y: 6)
                                )
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Community")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showCreatePost) {
                CommunityCreatePostView(viewModel: viewModel)
                    .environment(authService)
                    .presentationDragIndicator(.visible)
            }
            .alert("Error", isPresented: .init(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
        .task {
            viewModel.clearDisplayNamesIfStale()
            await viewModel.fetchPosts()
            if let userId = authService.currentUserId {
                let postIds = viewModel.posts.map(\.id)
                await viewModel.batchCheckLikedStatus(postIds: postIds, userId: userId)
            }
        }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        ZStack {
            Color(.systemBackground)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.orange.opacity(0.08), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .offset(x: -80, y: -200)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.yellow.opacity(0.05), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 160
                    )
                )
                .frame(width: 320, height: 320)
                .offset(x: 100, y: 200)
        }
        .ignoresSafeArea()
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Share Your Recipe")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 0.85, green: 0.35, blue: 0.1),
                            Color.orange,
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            Text("Discover and share delicious recipes")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }

    // MARK: - Sort Picker

    private var sortPicker: some View {
        HStack(spacing: 8) {
            ForEach(PostSort.allCases, id: \.self) { sort in
                Button {
                    Task { await viewModel.changeSortAndRefresh(sort) }
                } label: {
                    Text(sort.rawValue)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(viewModel.sortBy == sort ? .white : .secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background {
                            if viewModel.sortBy == sort {
                                Capsule().fill(
                                    LinearGradient(
                                        colors: [Color(red: 0.9, green: 0.4, blue: 0.1), .orange],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            } else {
                                Capsule().fill(.ultraThinMaterial)
                            }
                        }
                }
                .buttonStyle(.plain)
            }

            Spacer()
        }
    }

    // MARK: - Posts

    private var postsSection: some View {
        Group {
            if viewModel.isLoading && viewModel.posts.isEmpty {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Loading...")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 60)
            } else if viewModel.posts.isEmpty {
                EmptyStateView(
                    icon: "📝",
                    message: "No posts yet.\nBe the first to share a recipe!",
                    actionTitle: "Write a Post"
                ) {
                    showCreatePost = true
                }
                .padding(.top, 40)
            } else {
                LazyVStack(spacing: 14) {
                    ForEach(viewModel.posts) { post in
                        NavigationLink {
                            CommunityPostDetailView(
                                post: post,
                                viewModel: viewModel
                            )
                            .environment(authService)
                        } label: {
                            CommunityPostCard(
                                post: post,
                                isLiked: viewModel.likedPostIds.contains(post.id),
                                authorName: viewModel.displayName(for: post.userId)
                            )
                        }
                        .buttonStyle(.plain)
                        .onAppear {
                            // Trigger next page when 5th-to-last item appears
                            if post.id == viewModel.posts.dropLast(4).last?.id {
                                Task {
                                    await viewModel.fetchMorePosts()
                                    if let userId = authService.currentUserId {
                                        let newIds = viewModel.posts.map(\.id).filter { !viewModel.likedPostIds.contains($0) }
                                        if !newIds.isEmpty {
                                            await viewModel.batchCheckLikedStatus(postIds: newIds, userId: userId)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Bottom loading indicator
                    if viewModel.isFetchingMore {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                }
            }
        }
    }
}
