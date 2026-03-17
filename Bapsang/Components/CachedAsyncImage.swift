//
//  CachedAsyncImage.swift
//  Bapsang
//

import SwiftUI

struct CachedAsyncImage<Content: View>: View {
    let url: URL?
    @ViewBuilder let content: (AsyncImagePhase) -> Content

    @State private var phase: AsyncImagePhase = .empty

    var body: some View {
        content(phase)
            .task(id: url) {
                await load()
            }
    }

    private func load() async {
        phase = .empty
        guard let url else { return }

        if let image = await ImageCacheManager.shared.image(for: url) {
            phase = .success(Image(uiImage: image))
        } else {
            phase = .failure(URLError(.badServerResponse))
        }
    }
}
