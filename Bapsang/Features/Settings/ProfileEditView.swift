//
//  ProfileEditView.swift
//  Bapsang
//

import SwiftUI

struct ProfileEditView: View {
    @Environment(AuthService.self) private var authService
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel = ProfileEditViewModel()

    var body: some View {
        ZStack {
            background

            if viewModel.isLoading {
                ProgressView()
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        nameSection
                        spiceSection
                        dietarySection
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }

            if viewModel.isSaving {
                LoadingOverlay(message: "Saving...")
            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    guard let userId = authService.currentUserId else { return }
                    Task {
                        await viewModel.save(userId: userId)
                    }
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.orange)
                .disabled(viewModel.isSaving)
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
        .onChange(of: viewModel.didSave) { _, didSave in
            if didSave { dismiss() }
        }
        .task {
            guard let userId = authService.currentUserId else { return }
            await viewModel.load(userId: userId)
        }
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
                .offset(x: 120, y: -180)
        }
        .ignoresSafeArea()
    }

    // MARK: - Name

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("Display Name")

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

    // MARK: - Helpers

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 16, weight: .semibold))
    }
}

#Preview {
    NavigationStack {
        ProfileEditView()
            .environment(AuthService())
    }
}
