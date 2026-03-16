//
//  BapsangApp.swift
//  Bapsang
//
//  Created by Jun Lee on 3/16/26.
//

import SwiftUI

@main
struct BapsangApp: App {
    @State private var authService = AuthService()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(authService)
        }
    }
}
