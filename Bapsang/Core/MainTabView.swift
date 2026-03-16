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
            // 홈 — 식재료 선택 (Phase 2)
            PlaceholderView(icon: "🥔", title: "식재료 선택")
                .tabItem { Label("추천", systemImage: "fork.knife") }
            
            // 저장 (Phase 2)
            PlaceholderView(icon: "📖", title: "저장된 레시피")
                .tabItem { Label("저장", systemImage: "bookmark") }
            
            // 설정
            SettingsView()
                .tabItem { Label("설정", systemImage: "gearshape") }
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
