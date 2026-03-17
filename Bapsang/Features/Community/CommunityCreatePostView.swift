//
//  CommunityCreatePostView.swift
//  Bapsang
//

import SwiftUI
import PhotosUI

struct CommunityCreatePostView: View {
    @Bindable var viewModel: CommunityViewModel
    @Environment(AuthService.self) private var authService
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPhoto: PhotosPickerItem?

    private var isEditing: Bool { viewModel.editingPost != nil }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    imageSection
                    titleSection
                    descriptionSection
                    metaSection
                    ingredientsSection
                    stepsSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .navigationTitle(isEditing ? "Edit Recipe" : "New Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.editingPost = nil
                        viewModel.resetCreateForm()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Post") {
                        guard let userId = authService.currentUserId else { return }
                        Task {
                            let success: Bool
                            if isEditing {
                                success = await viewModel.updatePost(userId: userId)
                            } else {
                                success = await viewModel.createPost(userId: userId)
                            }
                            if success { dismiss() }
                        }
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.orange)
                    .disabled(viewModel.isSubmitting)
                }
            }
            .overlay {
                if viewModel.isSubmitting {
                    ZStack {
                        Color.black.opacity(0.3).ignoresSafeArea()
                        VStack(spacing: 12) {
                            ProgressView()
                            Text(isEditing ? "Saving..." : "Posting...")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.white)
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                        )
                    }
                }
            }
        }
    }

    // MARK: - Image

    private var imageSection: some View {
        PhotosPicker(selection: $selectedPhoto, matching: .images) {
            Group {
                if let data = viewModel.newImageData, let uiImage = UIImage(data: data) {
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 16))

                        Button {
                            viewModel.newImageData = nil
                            selectedPhoto = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(.white)
                                .shadow(radius: 2)
                                .padding(8)
                        }
                    }
                } else if isEditing, let imageUrl = viewModel.editingPost?.imageUrl, let url = URL(string: imageUrl) {
                    ZStack(alignment: .bottomTrailing) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            default:
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.gray.opacity(0.1))
                                    .frame(height: 200)
                                    .overlay { ProgressView() }
                            }
                        }

                        Text("Tap to change")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(.black.opacity(0.5)))
                            .padding(12)
                    }
                } else {
                    VStack(spacing: 10) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(.orange.opacity(0.6))

                        Text("Add Photo (Optional)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 140)
                    .background {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [8]))
                            .foregroundStyle(.orange.opacity(0.3))
                    )
                }
            }
        }
        .buttonStyle(.plain)
        .onChange(of: selectedPhoto) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    viewModel.newImageData = data
                }
            }
        }
    }

    // MARK: - Title

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            fieldLabel("Title")

            TextField("Recipe name", text: $viewModel.newTitle)
                .font(.system(size: 15))
                .padding(14)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                }
        }
    }

    // MARK: - Description

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            fieldLabel("Description (Optional)")

            TextEditor(text: $viewModel.newDescription)
                .font(.system(size: 14))
                .frame(height: 80)
                .padding(8)
                .scrollContentBackground(.hidden)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                }
        }
    }

    // MARK: - Meta

    private var metaSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Cooking Time
                VStack(alignment: .leading, spacing: 6) {
                    fieldLabel("Time (min)")
                    HStack {
                        Button {
                            if viewModel.newCookingTime > 5 {
                                viewModel.newCookingTime -= 5
                            }
                        } label: {
                            Image(systemName: "minus.circle")
                                .foregroundStyle(.orange)
                        }

                        Text("\(viewModel.newCookingTime)")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .frame(minWidth: 30)

                        Button {
                            viewModel.newCookingTime += 5
                        } label: {
                            Image(systemName: "plus.circle")
                                .foregroundStyle(.orange)
                        }
                    }
                    .padding(10)
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.ultraThinMaterial)
                    }
                }

                // Serving Size
                VStack(alignment: .leading, spacing: 6) {
                    fieldLabel("Servings")
                    HStack {
                        Button {
                            if viewModel.newServingSize > 1 {
                                viewModel.newServingSize -= 1
                            }
                        } label: {
                            Image(systemName: "minus.circle")
                                .foregroundStyle(.orange)
                        }

                        Text("\(viewModel.newServingSize)")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .frame(minWidth: 30)

                        Button {
                            viewModel.newServingSize += 1
                        } label: {
                            Image(systemName: "plus.circle")
                                .foregroundStyle(.orange)
                        }
                    }
                    .padding(10)
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.ultraThinMaterial)
                    }
                }
            }

            // Difficulty
            VStack(alignment: .leading, spacing: 6) {
                fieldLabel("Difficulty")
                HStack(spacing: 8) {
                    ForEach(["easy", "medium", "hard"], id: \.self) { level in
                        Button {
                            viewModel.newDifficulty = level
                        } label: {
                            Text(level.capitalized)
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundStyle(viewModel.newDifficulty == level ? .white : .secondary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background {
                                    if viewModel.newDifficulty == level {
                                        Capsule().fill(difficultyColor(level))
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
        }
    }

    // MARK: - Ingredients

    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                fieldLabel("Ingredients")
                Spacer()
                Button {
                    viewModel.addIngredientField()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(.orange)
                }
            }

            ForEach(Array(viewModel.newIngredients.enumerated()), id: \.offset) { index, _ in
                HStack(spacing: 8) {
                    Circle()
                        .fill(.orange.opacity(0.7))
                        .frame(width: 6, height: 6)

                    TextField("e.g. 2 cups rice", text: $viewModel.newIngredients[index])
                        .font(.system(size: 14))

                    if viewModel.newIngredients.count > 1 {
                        Button {
                            viewModel.removeIngredientField(at: index)
                        } label: {
                            Image(systemName: "minus.circle")
                                .font(.system(size: 16))
                                .foregroundStyle(.red.opacity(0.6))
                        }
                    }
                }
                .padding(12)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.ultraThinMaterial)
                }
            }
        }
    }

    // MARK: - Steps

    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                fieldLabel("Steps")
                Spacer()
                Button {
                    viewModel.addStepField()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(.orange)
                }
            }

            ForEach(Array(viewModel.newSteps.enumerated()), id: \.offset) { index, _ in
                HStack(alignment: .top, spacing: 10) {
                    Text("\(index + 1)")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(width: 24, height: 24)
                        .background(
                            Circle().fill(.orange)
                        )
                        .padding(.top, 2)

                    TextField("Describe this step...", text: $viewModel.newSteps[index], axis: .vertical)
                        .font(.system(size: 14))
                        .lineLimit(1...5)

                    if viewModel.newSteps.count > 1 {
                        Button {
                            viewModel.removeStepField(at: index)
                        } label: {
                            Image(systemName: "minus.circle")
                                .font(.system(size: 16))
                                .foregroundStyle(.red.opacity(0.6))
                        }
                    }
                }
                .padding(12)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.ultraThinMaterial)
                }
            }
        }
    }

    // MARK: - Helpers

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold, design: .rounded))
            .foregroundStyle(.secondary)
    }

    private func difficultyColor(_ level: String) -> Color {
        switch level {
        case "easy":   return .green
        case "medium": return .orange
        case "hard":   return .red
        default:       return .green
        }
    }
}
