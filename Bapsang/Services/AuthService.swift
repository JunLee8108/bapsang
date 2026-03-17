//
//  AuthService.swift
//  Bapsang
//
//  Created by Jun Lee on 3/16/26.
//

import Foundation
import Observation
import Supabase
import AuthenticationServices

@Observable
@MainActor
final class AuthService {
    
    // MARK: - State

    private(set) var session: Session?
    var isLoading = false
    var error: AuthError?
    var hasCompletedOnboarding = false
    private(set) var isCheckingOnboarding = false

    var isAuthenticated: Bool { session != nil }
    var currentUserId: UUID? { session?.user.id }
    var currentUserEmail: String? { session?.user.email }
    
    // MARK: - Init
    
    init() {
        Task { await restoreAndListen() }
    }
    
    // MARK: - Session Restore & Listener

    private func restoreAndListen() async {
        // 1) 기존 세션 복원 시도
        do {
            let session = try await supabase.auth.session
            if !session.isExpired {
                self.session = session
                await checkOnboardingStatus()
            } else {
                self.session = nil
            }
        } catch {
            self.session = nil
        }

        // 2) 이후 상태 변화 구독
        for await (event, session) in supabase.auth.authStateChanges {
            switch event {
            case .signedIn:
                self.session = session
                await checkOnboardingStatus()
            case .signedOut:
                self.session = nil
                self.hasCompletedOnboarding = false
            case .tokenRefreshed:
                self.session = session
            case .initialSession:
                if let session, !session.isExpired {
                    self.session = session
                    await checkOnboardingStatus()
                } else {
                    self.session = nil
                }
            default:
                break
            }
        }
    }

    // MARK: - Onboarding Check

    func checkOnboardingStatus() async {
        guard let userId = currentUserId else { return }
        isCheckingOnboarding = true
        defer { isCheckingOnboarding = false }

        do {
            let result: OnboardingStatus = try await supabase
                .from("users")
                .select("has_completed_onboarding")
                .eq("id", value: userId)
                .single()
                .execute()
                .value
            self.hasCompletedOnboarding = result.hasCompletedOnboarding
        } catch {
            // If query fails (e.g. column doesn't exist yet), default to true
            // so existing users aren't blocked
            self.hasCompletedOnboarding = true
        }
    }
    
    // MARK: - Apple Sign In
    
    func signInWithApple(credential: ASAuthorizationAppleIDCredential) async {
        guard let identityToken = credential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8) else {
            self.error = .custom("Apple 로그인 토큰을 가져올 수 없습니다.")
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let session = try await supabase.auth.signInWithIdToken(
                credentials: .init(
                    provider: .apple,
                    idToken: tokenString
                )
            )
            self.session = session
        } catch {
            self.error = .custom("Apple 로그인에 실패했습니다: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Google Sign In
    
    func signInWithGoogle() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await supabase.auth.signInWithOAuth(
                provider: .google,
                redirectTo: URL(string: "onemeal://login-callback")
            )
        } catch {
            self.error = .custom("Google 로그인에 실패했습니다: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Sign Out
    
    func signOut() async {
        do {
            try await supabase.auth.signOut()
            self.session = nil
        } catch {
            self.error = .custom("로그아웃에 실패했습니다.")
        }
    }
    
    // MARK: - Delete Account
    
    func deleteAccount() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await supabase.functions.invoke(
                "delete-user",
                options: .init(method: .post)
            )
            try await supabase.auth.signOut()
            self.session = nil
        } catch {
            self.error = .custom("계정 삭제에 실패했습니다.")
        }
    }
    
    // MARK: - Clear Error
    
    func clearError() {
        self.error = nil
    }
}

// MARK: - Onboarding Status

private struct OnboardingStatus: Codable {
    let hasCompletedOnboarding: Bool

    enum CodingKeys: String, CodingKey {
        case hasCompletedOnboarding = "has_completed_onboarding"
    }
}

// MARK: - Auth Error

enum AuthError: LocalizedError, Identifiable {
    case custom(String)
    
    var id: String { errorDescription ?? "unknown" }
    
    var errorDescription: String? {
        switch self {
        case .custom(let message):
            return message
        }
    }
}
