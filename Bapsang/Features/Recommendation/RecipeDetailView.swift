//
//  RecipeDetailView.swift
//  Bapsang
//

import SwiftUI

struct RecipeDetailView: View {
    let recipe: DefaultRecipe

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                heroSection
                metaBar
                ingredientsSection
                stepsSection
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .navigationTitle(recipe.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: 10) {
            RecipeImageView(recipe: recipe, size: 120, cornerRadius: 20)

            Text(recipe.name)
                .font(.system(size: 24, weight: .bold, design: .rounded))

            Text(recipe.koreanName)
                .font(.system(size: 16))
                .foregroundStyle(.secondary)

            Text(recipe.description)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }

    // MARK: - Meta Bar

    private var metaBar: some View {
        HStack(spacing: 0) {
            metaItem(icon: "clock", label: "\(recipe.cookingTime) min")
            Divider().frame(height: 28)
            metaItem(icon: "chart.bar", label: recipe.difficulty.label)
            Divider().frame(height: 28)
            metaItem(icon: "person.2", label: "\(recipe.servingSize) servings")
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

    // MARK: - Ingredients

    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(icon: "basket", title: "Ingredients")

            VStack(spacing: 0) {
                ForEach(Array(recipe.ingredients.enumerated()), id: \.offset) { index, ingredient in
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

                    if index < recipe.ingredients.count - 1 {
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
                ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
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
