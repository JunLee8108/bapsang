//
//  OnboardingView.swift
//  Bapsang
//

import SwiftUI

struct OnboardingView: View {
    @Environment(AuthService.self) private var authService

    @State private var viewModel = OnboardingViewModel()
    @State private var contentOpacity: Double = 0
    @State private var cardOffset: CGFloat = 30

    var body: some View {
        ZStack {
            background

            ScrollView {
                VStack(spacing: 28) {
                    headerSection
                    nameSection
                    spiceSection
                    dietarySection
                    actionButtons
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                .padding(.bottom, 40)
            }
            .opacity(contentOpacity)
            .offset(y: cardOffset)

            if viewModel.isLoading {
                LoadingOverlay(message: "Saving...")
            }
        }
        .alert("Error", isPresented: .init(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .onAppear { startAnimations() }
    }

    // MARK: - Background

    private var background: some View {
        ZStack {
            Color(.systemBackground)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.orange.opacity(0.15), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .offset(x: -80, y: -300)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.red.opacity(0.08), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 180
                    )
                )
                .frame(width: 360, height: 360)
                .offset(x: 120, y: 100)
        }
        .ignoresSafeArea()
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("🍚")
                .font(.system(size: 56))

            Text("Welcome to Bapsang!")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(red: 0.85, green: 0.35, blue: 0.1), .orange],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            Text("Tell us a bit about yourself\nso we can personalize your recipes")
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
    }

    // MARK: - Name

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("What should we call you?")

            TextField("Chef", text: $viewModel.displayName)
                .font(.system(size: 16))
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.orange.opacity(0.2), lineWidth: 0.5)
                )
        }
    }

    // MARK: - Spice Level

    private var spiceSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("Preferred Spice Level")

            HStack(spacing: 10) {
                ForEach(SpiceLevel.allCases) { level in
                    spiceButton(level)
                }
            }
        }
    }

    private func spiceButton(_ level: SpiceLevel) -> some View {
        let isSelected = viewModel.selectedSpiceLevel == level

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.selectedSpiceLevel = level
            }
        } label: {
            VStack(spacing: 6) {
                Text(level.icon)
                    .font(.system(size: 24))
                Text(level.label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(isSelected ? .white : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected
                          ? AnyShapeStyle(LinearGradient(
                              colors: [Color(red: 0.85, green: 0.35, blue: 0.1), .orange],
                              startPoint: .topLeading,
                              endPoint: .bottomTrailing
                          ))
                          : AnyShapeStyle(.ultraThinMaterial))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.clear : Color.orange.opacity(0.15), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Dietary Restrictions

    private var dietarySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("Dietary Restrictions")
            Text("Select all that apply")
                .font(.system(size: 13))
                .foregroundStyle(.tertiary)
                .padding(.top, -6)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 10),
                GridItem(.flexible(), spacing: 10)
            ], spacing: 10) {
                ForEach(DietaryRestriction.allCases) { restriction in
                    dietaryChip(restriction)
                }
            }
        }
    }

    private func dietaryChip(_ restriction: DietaryRestriction) -> some View {
        let isSelected = viewModel.selectedRestrictions.contains(restriction)

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                if isSelected {
                    viewModel.selectedRestrictions.remove(restriction)
                } else {
                    viewModel.selectedRestrictions.insert(restriction)
                }
            }
        } label: {
            HStack(spacing: 8) {
                Text(restriction.icon)
                    .font(.system(size: 16))
                Text(restriction.label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(isSelected ? .white : .primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected
                          ? AnyShapeStyle(LinearGradient(
                              colors: [Color(red: 0.85, green: 0.35, blue: 0.1), .orange],
                              startPoint: .topLeading,
                              endPoint: .bottomTrailing
                          ))
                          : AnyShapeStyle(.ultraThinMaterial))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.clear : Color.orange.opacity(0.15), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                guard let userId = authService.currentUserId else { return }
                Task {
                    if await viewModel.save(userId: userId) {
                        authService.hasCompletedOnboarding = true
                    }
                }
            } label: {
                Text("Let's Cook!")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.85, green: 0.35, blue: 0.1), .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: .orange.opacity(0.3), radius: 8, y: 4)
            }
            .buttonStyle(.plain)

            Button {
                guard let userId = authService.currentUserId else { return }
                Task {
                    if await viewModel.skip(userId: userId) {
                        authService.hasCompletedOnboarding = true
                    }
                }
            } label: {
                Text("Skip for now")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 8)
    }

    // MARK: - Helpers

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 16, weight: .semibold))
    }

    private func startAnimations() {
        withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
            contentOpacity = 1
        }
        withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.1)) {
            cardOffset = 0
        }
    }
}

#Preview {
    OnboardingView()
        .environment(AuthService())
}
