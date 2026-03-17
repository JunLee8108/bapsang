import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @Environment(AuthService.self) private var authService
    @Environment(\.openURL) private var openURL
    
    @State private var bowlOffset: CGFloat = -30
    @State private var steamOpacity: Double = 0
    @State private var contentOpacity: Double = 0
    @State private var buttonsOffset: CGFloat = 40
    
    @MainActor
    fileprivate static var currentCoordinator: AppleSignInCoordinator?
    
    var body: some View {
        @Bindable var authService = authService
        
        ZStack {
            background
            
            VStack(spacing: 0) {
                Spacer()
                
                heroSection
                    .opacity(contentOpacity)
                
                Spacer()
                Spacer()
                
                loginButtons
                    .opacity(contentOpacity)
                    .offset(y: buttonsOffset)
                
                termsFooter
                    .opacity(contentOpacity * 0.8)
                    .padding(.top, 24)
                    .padding(.bottom, 48)
            }
            .padding(.horizontal, 28)
            
            if authService.isLoading {
                LoadingOverlay(message: "Signing in...")
            }
        }
        .alert(item: $authService.error) { error in
            Alert(
                title: Text("Sign In Error"),
                message: Text(error.errorDescription ?? ""),
                dismissButton: .default(Text("OK")) {
                    authService.clearError()
                }
            )
        }
        .onAppear { startAnimations() }
    }
    
    // MARK: - Background
    
    private var background: some View {
        ZStack {
            Color(.systemBackground)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.orange.opacity(0.15), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .offset(x: -80, y: -300)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.red.opacity(0.08), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 180
                    )
                )
                .frame(width: 360, height: 360)
                .offset(x: 120, y: -180)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.yellow.opacity(0.06), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 160
                    )
                )
                .frame(width: 320, height: 320)
                .offset(x: -60, y: 300)
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Hero
    
    private var heroSection: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.1))
                    .frame(width: 140, height: 140)
                    .blur(radius: 20)
                
                VStack(spacing: 2) {
                    HStack(spacing: 8) {
                        SteamLine()
                        SteamLine(delay: 0.3)
                        SteamLine(delay: 0.6)
                    }
                    .opacity(steamOpacity)
                    .offset(y: -10)
                    
                    Text("🍚")
                        .font(.system(size: 72))
                        .offset(y: bowlOffset)
                }
            }
            .frame(height: 130)
            
            VStack(spacing: 10) {
                Text("Bapsang")
                    .font(.system(size: 38, weight: .heavy, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 0.85, green: 0.35, blue: 0.1),
                                Color.orange
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("Your K-Food Recipes")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .tracking(4)
            }
            
            Text("Just one ingredient from your fridge\nAI recommends today's Korean meal for one")
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(5)
                .padding(.top, 4)
        }
    }
    
    // MARK: - Login Buttons
    
    private var loginButtons: some View {
        VStack(spacing: 14) {
            Button {
                triggerAppleSignIn()
            } label: {
                loginButtonLabel(
                    icon: {
                        Image(systemName: "apple.logo")
                            .font(.system(size: 18, weight: .semibold))
                    },
                    text: "Continue with Apple"
                )
            }
            .buttonStyle(.plain)
            
            Button {
                Task { await authService.signInWithGoogle() }
            } label: {
                loginButtonLabel(
                    icon: {
                        Text("G")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(
                                .linearGradient(
                                    colors: [.blue, .red, .yellow, .green],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    },
                    text: "Continue with Google"
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    private func loginButtonLabel<Icon: View>(
        @ViewBuilder icon: () -> Icon,
        text: String
    ) -> some View {
        HStack(spacing: 10) {
            icon()
                .frame(width: 24)
            
            Text(text)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 54)
        .background {
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    LinearGradient(
                        colors: [Color.orange.opacity(0.3), Color.orange.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
        )
    }
    
    // MARK: - Terms Footer
    
    private var termsFooter: some View {
        VStack(spacing: 6) {
            Text("By continuing, you agree to the following")
                .font(.system(size: 11))
                .foregroundStyle(.quaternary)
            
            HStack(spacing: 3) {
                Button("Terms of Service") {
                    if let url = URL(string: "https://yourapp.com/terms") {
                        openURL(url)
                    }
                }
                
                Text("and")
                    .foregroundStyle(.tertiary)
                
                Button("Privacy Policy") {
                    if let url = URL(string: "https://yourapp.com/privacy") {
                        openURL(url)
                    }
                }
            }
            .font(.system(size: 11, weight: .medium))
            .tint(.orange)
        }
    }
    
    // MARK: - Animations
    
    private func startAnimations() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.65).delay(0.1)) {
            bowlOffset = 0
        }
        withAnimation(.easeOut(duration: 0.8).delay(0.5)) {
            steamOpacity = 1
        }
        withAnimation(.easeOut(duration: 0.7).delay(0.2)) {
            contentOpacity = 1
        }
        withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.4)) {
            buttonsOffset = 0
        }
    }
    
    // MARK: - Apple Sign In
    
    private func triggerAppleSignIn() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        let coordinator = AppleSignInCoordinator(authService: authService)
        controller.delegate = coordinator
        
        Self.currentCoordinator = coordinator
        controller.performRequests()
    }
}

// MARK: - Apple Sign In Coordinator

@MainActor
final class AppleSignInCoordinator: NSObject, ASAuthorizationControllerDelegate {
    private let authService: AuthService
    
    init(authService: AuthService) {
        self.authService = authService
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
        Task { await authService.signInWithApple(credential: credential) }
        LoginView.currentCoordinator = nil
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        if (error as NSError).code != 1001 {
            authService.error = .custom("Apple sign in failed: \(error.localizedDescription)")
        }
        LoginView.currentCoordinator = nil
    }
}

// MARK: - Steam Animation Component

struct SteamLine: View {
    var delay: Double = 0
    @State private var animate = false
    
    var body: some View {
        Capsule()
            .fill(Color.white.opacity(0.4))
            .frame(width: 3, height: 18)
            .offset(y: animate ? -12 : 0)
            .opacity(animate ? 0 : 0.6)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.4)
                    .repeatForever(autoreverses: false)
                    .delay(delay)
                ) {
                    animate = true
                }
            }
    }
}

#Preview {
    LoginView()
        .environment(AuthService())
}
