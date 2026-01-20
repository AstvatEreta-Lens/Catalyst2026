//
//  AppAuthState.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 06/01/26.
//  Updated by Rifqi Rahman on 19/01/26.
//
//  Global authentication state manager for the app.
//  Handles session persistence, splash screen, and onboarding flow.
//
//  BACKEND DEVELOPER NOTES:
//  -------------------------
//  Authentication State Management:
//  1. isAuthenticated: Whether user has valid auth session
//  2. needsOnboarding: Whether user needs to complete profile setup
//  3. showSplash: Whether to show splash screen (first launch)
//
//  Session Restoration:
//  - On app launch, check Keychain for stored Apple User ID
//  - Verify credential state with Apple's servers
//  - Check if user has completed onboarding (UserEntity.hasCompletedOnboarding)
//
//  CloudKit Sync Considerations:
//  - Onboarding status should sync across devices
//  - If user completed onboarding on device A, device B should skip it
//  - Use UserEntity.hasCompletedOnboarding as source of truth
//

import Foundation
import Combine
import AuthenticationServices

@MainActor
final class AppAuthState: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Whether the user is authenticated
    @Published var isAuthenticated: Bool = false
    
    /// Whether the user needs to complete onboarding
    @Published var needsOnboarding: Bool = false
    
    /// Whether to show splash screen
    @Published var showSplash: Bool = true
    
    // MARK: - Private Properties
    
    /// Key for storing first launch status
    private let hasLaunchedBeforeKey = "hasLaunchedBefore"
    
    // MARK: - Init
    
    init() {
        checkFirstLaunch()
        restoreSession()
    }
    
    // MARK: - First Launch Check
    
    /// Checks if this is the first app launch
    private func checkFirstLaunch() {
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: hasLaunchedBeforeKey)
        showSplash = !hasLaunchedBefore
    }
    
    /// Marks that splash has been shown
    func dismissSplash() {
        UserDefaults.standard.set(true, forKey: hasLaunchedBeforeKey)
        showSplash = false
    }
    
    // MARK: - Session Restoration
    
    /// Attempts to restore previous authentication session
    func restoreSession() {
        guard let appleUserID = KeychainService.load(for: "appleUserID") else {
            isAuthenticated = false
            return
        }
        
        let provider = ASAuthorizationAppleIDProvider()
        provider.getCredentialState(forUserID: appleUserID) { state, _ in
            DispatchQueue.main.async {
                self.isAuthenticated = (state == .authorized)
                
                // BACKEND NOTE: Check if user has completed onboarding
                // This should query UserEntity.hasCompletedOnboarding from SwiftData
                // For now, we assume onboarding is complete for restored sessions
                if state == .authorized {
                    self.needsOnboarding = false
                }
            }
        }
    }
    
    // MARK: - Logout
    
    /// Clears authentication state and logs out user
    func logout() {
        KeychainService.delete(for: "appleUserID")
        isAuthenticated = false
        needsOnboarding = false
        // Note: Don't reset showSplash - user has already seen it
    }
    
    // MARK: - Onboarding
    
    /// Call this when a new user signs up to trigger onboarding
    func triggerOnboarding() {
        needsOnboarding = true
    }
    
    /// Call this when onboarding is complete
    func completeOnboarding() {
        needsOnboarding = false
    }
}
