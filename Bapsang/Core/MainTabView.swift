//
//  MainTabView.swift
//  Bapsang
//
//  Created by Jun Lee on 3/16/26.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            RecommendationView()
                .tabItem { Label("Recommend", systemImage: "fork.knife") }

            CommunityView()
                .tabItem { Label("Community", systemImage: "bubble.left.and.bubble.right") }

            PlaceholderView(icon: "📖", title: "Saved Recipes")
                .tabItem { Label("Saved", systemImage: "bookmark") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .tint(.orange)
    }
}

// MARK: - Placeholder (Phase 2 화면용 임시 뷰)

struct PlaceholderView: View {
    let icon: String
    let title: String
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Text(icon)
                    .font(.system(size: 60))
                Text(title)
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("오늘 뭐 먹지?")
        }
    }
}
