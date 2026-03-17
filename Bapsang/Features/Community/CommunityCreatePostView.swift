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

    // Image repositioning state
    @State private var imageOffset: CGSize = .zero
    @State private var dragAccumulated: CGSize = .zero
    @State private var imageFrameWidth: CGFloat = 0

    private let imageFrameHeight: CGFloat = 200

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
                        // Crop image to visible region before uploading,
                        // then reset offset so the view doesn't visually jump.
                        applyCroppedImage()
                        resetImageOffset()
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
        Group {
            if let data = viewModel.newImageData, let uiImage = UIImage(data: data) {
                // Selected image with drag-to-reposition
                GeometryReader { geo in
                    let frameWidth = geo.size.width
                    let maxOffset = calcMaxOffset(imageSize: uiImage.size, frameWidth: frameWidth)
                    let _ = DispatchQueue.main.async { imageFrameWidth = frameWidth }

                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .offset(imageOffset)
                            .frame(width: frameWidth, height: imageFrameHeight)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        let newX = dragAccumulated.width + value.translation.width
                                        let newY = dragAccumulated.height + value.translation.height
                                        imageOffset = CGSize(
                                            width: clamp(newX, max: maxOffset.width),
                                            height: clamp(newY, max: maxOffset.height)
                                        )
                                    }
                                    .onEnded { value in
                                        let newX = dragAccumulated.width + value.translation.width
                                        let newY = dragAccumulated.height + value.translation.height
                                        dragAccumulated = CGSize(
                                            width: clamp(newX, max: maxOffset.width),
                                            height: clamp(newY, max: maxOffset.height)
                                        )
                                    }
                            )

                        // Action buttons
                        HStack(spacing: 6) {
                            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                                Image(systemName: "arrow.triangle.2.circlepath.camera.fill")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.white)
                                    .padding(8)
                                    .background(Circle().fill(.black.opacity(0.5)))
                            }

                            Button {
                                viewModel.newImageData = nil
                                selectedPhoto = nil
                                resetImageOffset()
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .padding(8)
                                    .background(Circle().fill(.black.opacity(0.5)))
                            }
                        }
                        .padding(8)
                    }
                    .overlay(alignment: .bottom) {
                        if maxOffset.width > 0 || maxOffset.height > 0 {
                            Text("Drag to reposition")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Capsule().fill(.black.opacity(0.45)))
                                .padding(.bottom, 10)
                                .allowsHitTesting(false)
                        }
                    }
                }
                .frame(height: imageFrameHeight)
            } else if isEditing, let imageUrl = viewModel.editingPost?.imageUrl, let url = URL(string: imageUrl) {
                // Existing image in edit mode — tap to change
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    ZStack(alignment: .bottomTrailing) {
                        CachedAsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                Color.clear
                                    .frame(height: imageFrameHeight)
                                    .overlay {
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    }
                                    .clipped()
                                    .contentShape(Rectangle())
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            default:
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.gray.opacity(0.1))
                                    .frame(height: imageFrameHeight)
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
                }
                .buttonStyle(.plain)
            } else {
                // Empty state — tap to add photo
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
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
                .buttonStyle(.plain)
            }
        }
        .onChange(of: selectedPhoto) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    viewModel.newImageData = data
                    resetImageOffset()
                }
            }
        }
    }

    // MARK: - Image Repositioning Helpers

    /// Calculate max draggable offset based on how much the image overflows the frame
    private func calcMaxOffset(imageSize: CGSize, frameWidth: CGFloat) -> CGSize {
        guard imageSize.width > 0, imageSize.height > 0 else { return .zero }
        let scale = max(frameWidth / imageSize.width, imageFrameHeight / imageSize.height)
        let scaledW = imageSize.width * scale
        let scaledH = imageSize.height * scale
        return CGSize(
            width: max(0, (scaledW - frameWidth) / 2),
            height: max(0, (scaledH - imageFrameHeight) / 2)
        )
    }

    private func clamp(_ value: CGFloat, max limit: CGFloat) -> CGFloat {
        min(max(value, -limit), limit)
    }

    private func resetImageOffset() {
        imageOffset = .zero
        dragAccumulated = .zero
    }

    /// Replace image data with cropped version matching the visible region.
    /// Always crops — even when offset is zero — so the uploaded image
    /// exactly matches what the user sees in the preview.
    private func applyCroppedImage() {
        guard let data = viewModel.newImageData,
              let uiImage = UIImage(data: data),
              imageFrameWidth > 0 else { return }

        let cropped = cropImage(uiImage, frameWidth: imageFrameWidth)
        if let jpegData = cropped.jpegData(compressionQuality: 0.85) {
            viewModel.newImageData = jpegData
        }
    }

    /// Normalize UIImage so its pixel data matches the displayed orientation.
    /// After this call, `cgImage` pixels are in the same orientation as `size`.
    private func normalizeOrientation(_ image: UIImage) -> UIImage {
        guard image.imageOrientation != .up else { return image }
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: image.size))
        let normalized = UIGraphicsGetImageFromCurrentImageContext() ?? image
        UIGraphicsEndImageContext()
        return normalized
    }

    /// Crop image to the visible region based on current offset.
    private func cropImage(_ uiImage: UIImage, frameWidth: CGFloat) -> UIImage {
        let normalized = normalizeOrientation(uiImage)
        guard normalized.size.width > 0, normalized.size.height > 0 else { return uiImage }

        let imgW = normalized.size.width
        let imgH = normalized.size.height
        let scale = max(frameWidth / imgW, imageFrameHeight / imgH)
        let scaledW = imgW * scale
        let scaledH = imgH * scale

        // Center of scaled image + offset → visible rect origin in scaled coords
        let visibleX = (scaledW - frameWidth) / 2 - imageOffset.width
        let visibleY = (scaledH - imageFrameHeight) / 2 - imageOffset.height

        // Convert back to original image coordinates
        let cropRect = CGRect(
            x: visibleX / scale,
            y: visibleY / scale,
            width: frameWidth / scale,
            height: imageFrameHeight / scale
        )

        guard let cgImage = normalized.cgImage?.cropping(to: cropRect) else { return uiImage }
        return UIImage(cgImage: cgImage, scale: normalized.scale, orientation: .up)
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

            ForEach($viewModel.newIngredients) { $field in
                HStack(spacing: 8) {
                    Circle()
                        .fill(.orange.opacity(0.7))
                        .frame(width: 6, height: 6)

                    TextField("e.g. 2 cups rice", text: $field.value)
                        .font(.system(size: 14))

                    if viewModel.newIngredients.count > 1 {
                        Button {
                            viewModel.removeIngredientField(id: field.id)
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

            ForEach(Array(viewModel.newSteps.enumerated()), id: \.element.id) { index, field in
                HStack(alignment: .top, spacing: 10) {
                    Text("\(index + 1)")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(width: 24, height: 24)
                        .background(
                            Circle().fill(.orange)
                        )
                        .padding(.top, 2)

                    TextField("Describe this step...", text: Binding(
                        get: { viewModel.newSteps.first(where: { $0.id == field.id })?.value ?? "" },
                        set: { newValue in
                            if let i = viewModel.newSteps.firstIndex(where: { $0.id == field.id }) {
                                viewModel.newSteps[i].value = newValue
                            }
                        }
                    ), axis: .vertical)
                        .font(.system(size: 14))
                        .lineLimit(1...5)

                    if viewModel.newSteps.count > 1 {
                        Button {
                            viewModel.removeStepField(id: field.id)
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
