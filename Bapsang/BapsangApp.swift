//
//  BapsangApp.swift
//  Bapsang
//
//  Created by Jun Lee on 3/16/26.
//

import SwiftUI
import Supabase

@main
struct BapsangApp: App {
    @State private var authService = AuthService()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(authService)
                .onOpenURL { url in
                    Task {
                        try? await supabase.auth.session(from: url)
                    }
                }
        }
    }
}
