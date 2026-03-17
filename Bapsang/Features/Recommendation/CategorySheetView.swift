//
//  CategorySheetView.swift
//  Bapsang
//

import SwiftUI

struct CategorySheetView: View {
    let category: RecipeCategory
    let recipes: [DefaultRecipe]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    headerSection

                    ForEach(recipes) { recipe in
                        NavigationLink(value: recipe) {
                            RecipeRowContent(recipe: recipe)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
            .navigationTitle(category.name)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: DefaultRecipe.self) { recipe in
                RecipeDetailView(recipe: recipe)
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 6) {
            Text(category.icon)
                .font(.system(size: 44))

            Text(category.description)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Text("\(recipes.count) recipes")
                .font(.system(size: 12))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }
}

// MARK: - Recipe Row Content

private struct RecipeRowContent: View {
    let recipe: DefaultRecipe

    var body: some View {
        HStack(spacing: 14) {
                RecipeImageView(recipe: recipe, size: 48, cornerRadius: 12)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(recipe.name)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(.primary)

                        Text(recipe.koreanName)
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }

                    Text(recipe.description)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    HStack(spacing: 12) {
                        Label("\(recipe.cookingTime)min", systemImage: "clock")
                        Label(recipe.difficulty.label, systemImage: "chart.bar")
                    }
                    .font(.system(size: 11))
                    .foregroundStyle(.tertiary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
        }
    }
}
