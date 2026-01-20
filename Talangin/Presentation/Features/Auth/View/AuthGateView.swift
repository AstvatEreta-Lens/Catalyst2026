//
//  AuthGateView.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 06/01/26.
//  Updated by Rifqi Rahman on 19/01/26.
//
//  Root view that manages the app's authentication flow.
//  Handles splash screen, authentication, onboarding, and main app navigation.
//
//  BACKEND DEVELOPER NOTES:
//  -------------------------
//  App Flow States:
//  1. Splash Screen: First time user opens the app
//  2. Sign In/Sign Up: User authentication
//  3. Onboarding: New user profile setup (name + payment)
//  4. Main App: Authenticated user experience
//
//  State Transitions:
//  - Splash → SignIn: User taps "Start Expense"
//  - SignIn → Onboarding: New user signs up successfully
//  - SignIn → MainApp: Existing user signs in
//  - Onboarding → MainApp: User completes or skips setup
//
//  Deep Linking Considerations:
//  - Handle app opened via deep link
//  - Skip splash if app was backgrounded briefly
//  - Restore correct state after app restart
//

import SwiftUI
import SwiftData

struct AuthGateView: View {
    
    // MARK: - Environment
    @EnvironmentObject private var authState: AppAuthState
    
    var body: some View {
        Group {
            if authState.showSplash {
                // MARK: - Splash Screen
                SplashView {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        authState.dismissSplash()
                    }
                }
                .transition(.opacity)
                
            } else if !authState.isAuthenticated {
                // MARK: - Authentication
                SignInView()
                    .transition(.opacity)
                
            } else if authState.needsOnboarding {
                // MARK: - Onboarding
                OnboardingContainerView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                
            } else {
                // MARK: - Main App
                MainTabView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authState.showSplash)
        .animation(.easeInOut(duration: 0.3), value: authState.isAuthenticated)
        .animation(.easeInOut(duration: 0.3), value: authState.needsOnboarding)
    }
}

#Preview {
    AuthGateView()
        .environmentObject(AppAuthState())
}
