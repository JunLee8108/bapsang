//
//  RecommendationView.swift
//  Bapsang
//

import SwiftUI

struct RecommendationView: View {
    @State private var viewModel = RecommendationViewModel()
    @State private var appearAnimations: [Bool] = []

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    greetingSection
                    ctaButton
                    categoriesSection
                    recentRecipesSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .navigationTitle("What Should I Eat?")
            .background(backgroundGradient)
            .sheet(isPresented: $viewModel.showCategorySheet) {
                if let category = viewModel.selectedCategory {
                    CategorySheetView(
                        category: category,
                        recipes: viewModel.recipesForSelectedCategory
                    )
                    .presentationDragIndicator(.visible)
                }
            }
        }
        .onAppear { triggerStaggerAnimation() }
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

    // MARK: - Greeting

    private var greetingSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(viewModel.greeting)
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

            Text(viewModel.subtitle)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }

    // MARK: - CTA Button

    private var ctaButton: some View {
        Button {
            // Phase 2: navigate to ingredient selection
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "carrot.fill")
                    .font(.system(size: 18))

                Text("Select Ingredients")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.9, green: 0.4, blue: 0.1),
                                Color.orange,
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: .orange.opacity(0.3), radius: 12, y: 6)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Categories

    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Today's Recommended Categories")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)

            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(Array(viewModel.categories.enumerated()), id: \.element.id) { index, category in
                    CategoryCard(category: category) {
                        viewModel.selectCategory(category)
                    }
                    .opacity(animationValue(for: index) ? 1 : 0)
                    .offset(y: animationValue(for: index) ? 0 : 20)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.8)
                            .delay(Double(index) * 0.08),
                        value: animationValue(for: index)
                    )
                }
            }
        }
    }

    // MARK: - Recent Recipes

    private var recentRecipesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Recent Recipes")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)

            EmptyStateView(
                icon: "📭",
                message: "No recipes yet.\nStart exploring!",
                actionTitle: "Select Ingredients"
            ) {
                // Phase 2: navigate to ingredient selection
            }
        }
    }

    // MARK: - Animation Helpers

    private func animationValue(for index: Int) -> Bool {
        index < appearAnimations.count && appearAnimations[index]
    }

    private func triggerStaggerAnimation() {
        let count = viewModel.categories.count
        appearAnimations = Array(repeating: false, count: count)

        for i in 0..<count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.08) {
                if i < appearAnimations.count {
                    appearAnimations[i] = true
                }
            }
        }
    }
}

#Preview {
    RecommendationView()
}
