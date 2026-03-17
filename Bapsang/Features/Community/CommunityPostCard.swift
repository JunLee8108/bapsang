//
//  CommunityPostCard.swift
//  Bapsang
//

import SwiftUI

struct CommunityPostCard: View {
    let post: CommunityPost
    let isLiked: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: author + badge + time
            HStack(spacing: 8) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.orange.opacity(0.7))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Chef")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))

                    Text(post.timeAgo)
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                }

                Spacer()

                // Difficulty pill
                if let difficulty = post.difficulty {
                    Text(post.difficultyLabel)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(difficultyColor(difficulty))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(difficultyColor(difficulty).opacity(0.12))
                        )
                }
            }

            // Title
            Text(post.title)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .lineLimit(2)

            // Image
            if let imageUrl = post.imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        Color.clear
                            .frame(height: 200)
                            .overlay {
                                image
                                    .resizable()
                                    .scaledToFill()
                            }
                            .clipped()
                            .contentShape(Rectangle())
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    case .failure:
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.gray.opacity(0.15))
                            .frame(height: 180)
                            .overlay {
                                Image(systemName: "photo")
                                    .font(.system(size: 30))
                                    .foregroundStyle(.tertiary)
                            }
                    default:
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.gray.opacity(0.1))
                            .frame(height: 180)
                            .overlay { ProgressView() }
                    }
                }
            }

            // Description
            if let description = post.description, !description.isEmpty {
                Text(description)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            // Meta row
            HStack(spacing: 16) {
                if let time = post.cookingTime {
                    metaItem(icon: "clock", text: "\(time) min")
                }
                if let serving = post.servingSize {
                    metaItem(icon: "person.2", text: "\(serving) servings")
                }

                Spacer()

                // Likes
                HStack(spacing: 4) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .font(.system(size: 13))
                        .foregroundStyle(isLiked ? .red : .secondary)
                    Text("\(post.likesCount)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                }

                // Comments
                HStack(spacing: 4) {
                    Image(systemName: "bubble.right")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                    Text("\(post.commentsCount)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(16)
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

    private func metaItem(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundStyle(.orange)
            Text(text)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)
        }
    }

    private func difficultyColor(_ difficulty: String) -> Color {
        switch difficulty {
        case "easy":   return .green
        case "medium": return .orange
        case "hard":   return .red
        default:       return .green
        }
    }
}
