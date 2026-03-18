//
//  SavedView.swift
//  Bapsang
//

import SwiftUI

struct SavedView: View {
    @Environment(AuthService.self) private var authService
    @State private var viewModel = SavedViewModel()
    @State private var communityViewModel = CommunityViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient

                ScrollView {
                    VStack(spacing: 16) {
                        headerSection
                        tabPicker
                        contentSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
                .refreshable {
                    guard let userId = authService.currentUserId else { return }
                    await viewModel.fetchSaved(userId: userId)
                }
            }
            .navigationTitle("Saved")
            .navigationBarTitleDisplayMode(.inline)
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
            guard let userId = authService.currentUserId else { return }
            viewModel.clearDisplayNamesIfStale()
            viewModel.clearSavedCacheIfStale()
            viewModel.clearCommunityPostsIfStale()
            await viewModel.loadSavedIds(userId: userId)
            await viewModel.fetchSavedIfNeeded(userId: userId)
            communityViewModel.authorNames.merge(viewModel.authorNames) { _, new in new }
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
            Text("Saved Recipes")
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

            Text("Your bookmarked recipes")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }

    // MARK: - Tab Picker

    private var tabPicker: some View {
        HStack(spacing: 8) {
            ForEach(SavedSourceType.allCases, id: \.self) { tab in
                Button {
                    viewModel.selectedTab = tab
                    guard let userId = authService.currentUserId else { return }
                    Task {
                        await viewModel.fetchSavedIfNeeded(userId: userId)
                        communityViewModel.authorNames.merge(viewModel.authorNames) { _, new in new }
                    }
                } label: {
                    Text(tab.label)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(viewModel.selectedTab == tab ? .white : .secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background {
                            if viewModel.selectedTab == tab {
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

    // MARK: - Content

    @ViewBuilder
    private var contentSection: some View {
        switch viewModel.selectedTab {
        case .default:
            if viewModel.isLoadingDefault {
                loadingIndicator
            } else {
                defaultRecipesSection
            }
        case .community:
            if viewModel.isLoadingCommunity {
                loadingIndicator
            } else {
                communityPostsSection
            }
        }
    }

    private var loadingIndicator: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading...")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    // MARK: - Default Recipes

    private var defaultRecipesSection: some View {
        Group {
            if viewModel.savedDefaultRecipes.isEmpty {
                EmptyStateView(
                    icon: "📖",
                    message: "No saved recipes yet.\nBookmark recipes from the Recommend tab!"
                )
                .padding(.top, 40)
            } else {
                LazyVStack(spacing: 14) {
                    ForEach(viewModel.savedDefaultRecipes) { recipe in
                        NavigationLink {
                            RecipeDetailView(recipe: recipe)
                        } label: {
                            SavedDefaultRecipeCard(recipe: recipe)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Community Posts

    private var communityPostsSection: some View {
        Group {
            if viewModel.savedCommunityPosts.isEmpty {
                EmptyStateView(
                    icon: "💬",
                    message: "No saved community recipes yet.\nBookmark recipes from the Community tab!"
                )
                .padding(.top, 40)
            } else {
                LazyVStack(spacing: 14) {
                    ForEach(viewModel.savedCommunityPosts) { post in
                        NavigationLink {
                            CommunityPostDetailView(
                                post: post,
                                viewModel: communityViewModel
                            )
                            .environment(authService)
                            .onDisappear {
                                viewModel.applyLikeDeltas(from: communityViewModel)
                                viewModel.applyCommentDeltas(from: communityViewModel)
                            }
                        } label: {
                            SavedCommunityPostCard(
                                post: post,
                                authorName: viewModel.displayName(for: post.userId)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

// MARK: - Default Recipe Card

private struct SavedDefaultRecipeCard: View {
    let recipe: DefaultRecipe

    var body: some View {
        HStack(spacing: 14) {
            RecipeImageView(recipe: recipe, size: 72, cornerRadius: 12)

            VStack(alignment: .leading, spacing: 6) {
                Text(recipe.name)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .lineLimit(1)

                Text(recipe.koreanName)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 11))
                            .foregroundStyle(.orange)
                        Text("\(recipe.cookingTime) min")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.secondary)
                    }

                    HStack(spacing: 4) {
                        Image(systemName: "chart.bar")
                            .font(.system(size: 11))
                            .foregroundStyle(.orange)
                        Text(recipe.difficulty.label)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.secondary)
                    }

                    HStack(spacing: 4) {
                        Image(systemName: "person.2")
                            .font(.system(size: 11))
                            .foregroundStyle(.orange)
                        Text("\(recipe.servingSize)")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [Color.orange.opacity(0.2), Color.orange.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
        )
    }
}

// MARK: - Community Post Card

private struct SavedCommunityPostCard: View {
    let post: CommunityPost
    let authorName: String

    var body: some View {
        HStack(spacing: 14) {
            // Thumbnail
            if let imageUrl = post.imageUrl, let url = URL(string: imageUrl) {
                CachedAsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        Color.clear
                            .overlay { image.resizable().scaledToFill() }
                            .clipped()
                            .contentShape(Rectangle())
                    case .failure:
                        imagePlaceholder
                    default:
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                imagePlaceholder
                    .frame(width: 72, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(post.title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .lineLimit(1)

                Text(authorName)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    if let time = post.cookingTime {
                        metaItem(icon: "clock", text: "\(time) min")
                    }
                    if post.difficulty != nil {
                        metaItem(icon: "chart.bar", text: post.difficultyLabel)
                    }
                    metaItem(icon: "heart.fill", text: "\(post.likesCount)", color: .red.opacity(0.6))
                    metaItem(icon: "bubble.right", text: "\(post.commentsCount)")
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [Color.orange.opacity(0.2), Color.orange.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
        )
    }

    private var imagePlaceholder: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.gray.opacity(0.15))
            .overlay {
                Image(systemName: "photo")
                    .font(.system(size: 20))
                    .foregroundStyle(.tertiary)
            }
    }

    private func metaItem(icon: String, text: String, color: Color = .orange) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundStyle(color)
            Text(text)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)
        }
    }
}
