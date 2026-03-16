//
//  RootView.swift
//  Bapsang
//
//  Created by Jun Lee on 3/16/26.
//

import SwiftUI

struct RootView: View {
    @Environment(AuthService.self) private var authService
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                MainTabView()
                    .transition(.opacity)
            } else {
                LoginView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authService.isAuthenticated)
    }
}
