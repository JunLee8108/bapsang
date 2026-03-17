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

            SavedView()
                .tabItem { Label("Saved", systemImage: "bookmark") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .tint(.orange)
    }
}

