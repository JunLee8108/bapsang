//
//  BookmarkButton.swift
//  Bapsang
//

import SwiftUI

struct BookmarkButton: View {
    let sourceType: SavedSourceType
    let sourceId: UUID
    let userId: UUID

    @State private var isSaved = false
    @State private var isLoading = true

    private let service = SavedService()

    var body: some View {
        Button {
            Task { await toggle() }
        } label: {
            Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                .font(.system(size: 18))
                .foregroundStyle(isSaved ? .orange : .secondary)
                .animation(.spring(response: 0.3), value: isSaved)
        }
        .disabled(isLoading)
        .task {
            await checkSaved()
        }
    }

    private func checkSaved() async {
        do {
            isSaved = try await service.checkIfSaved(
                userId: userId, sourceType: sourceType, sourceId: sourceId
            )
        } catch {}
        isLoading = false
    }

    private func toggle() async {
        let wasSaved = isSaved
        isSaved.toggle() // Optimistic update

        do {
            if wasSaved {
                try await service.unsaveItem(userId: userId, sourceType: sourceType, sourceId: sourceId)
            } else {
                try await service.saveItem(userId: userId, sourceType: sourceType, sourceId: sourceId)
            }
            NotificationCenter.default.post(
                name: .savedItemChanged,
                object: nil,
                userInfo: ["sourceType": sourceType.rawValue, "sourceId": sourceId]
            )
        } catch {
            isSaved = wasSaved // Revert on error
        }
    }
}
