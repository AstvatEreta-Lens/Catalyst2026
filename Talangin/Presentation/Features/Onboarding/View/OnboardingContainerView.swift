//
//  OnboardingContainerView.swift
//  Talangin
//
//  Created by Rifqi Rahman on 19/01/26.
//
//  Container view that manages the multi-step onboarding flow.
//  Handles navigation between name and payment setup steps.
//
//  BACKEND DEVELOPER NOTES:
//  -------------------------
//  Onboarding Flow Management:
//  1. Step 1: Collect display name → Update UserEntity.fullName
//  2. Step 2: Collect payment info → Create PaymentMethodEntity
//  3. Mark onboarding complete → Set UserEntity.hasCompletedOnboarding = true
//
//  Data Persistence:
//  - All data should be saved to SwiftData/CloudKit
//  - Consider syncing onboarding status across devices
//  - Handle partial completion (user closes app mid-onboarding)
//
//  State Management:
//  - Track current step in AppAuthState or UserDefaults
//  - Allow resuming onboarding if interrupted
//  - Clear onboarding state after completion
//

import SwiftUI
import SwiftData

struct OnboardingContainerView: View {
    
    // MARK: - Environment
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var authState: AppAuthState
    
    // MARK: - State
    @State private var currentStep: OnboardingStep = .name
    @State private var displayName: String = ""
    
    // MARK: - Onboarding Steps
    enum OnboardingStep {
        case name
        case payment
    }
    
    var body: some View {
        Group {
            switch currentStep {
            case .name:
                OnboardingNameView { name in
                    displayName = name
                    currentStep = .payment
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))
                
            case .payment:
                OnboardingPaymentView(
                    onComplete: { bankName, accountNumber, holderName in
                        completeOnboarding(
                            displayName: displayName,
                            bankName: bankName,
                            accountNumber: accountNumber,
                            holderName: holderName
                        )
                    },
                    onSkip: {
                        completeOnboarding(
                            displayName: displayName,
                            bankName: nil,
                            accountNumber: nil,
                            holderName: nil
                        )
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentStep)
    }
    
    // MARK: - Complete Onboarding
    
    /// Saves user data and marks onboarding as complete
    /// - Parameters:
    ///   - displayName: User's display name
    ///   - bankName: Optional bank/wallet name
    ///   - accountNumber: Optional account number
    ///   - holderName: Optional account holder name
    private func completeOnboarding(
        displayName: String,
        bankName: String?,
        accountNumber: String?,
        holderName: String?
    ) {
        // BACKEND NOTE: Save onboarding data to SwiftData
        // This should update the current user's profile and create payment method
        
        // Get the current user from context
        let userRepository = UserRepository(context: modelContext)
        
        do {
            // Get or create user
            if let appleUserId = KeychainService.load(for: "appleUserID"),
               let user = try userRepository.getUser(by: appleUserId) {
                
                // Update display name
                user.fullName = displayName
                
                // Create payment method if provided
                if let bankName = bankName,
                   let accountNumber = accountNumber,
                   let holderName = holderName {
                    
                    let paymentMethod = PaymentMethodEntity(
                        providerName: bankName,
                        destination: accountNumber,
                        holderName: holderName,
                        isDefault: true,
                        user: user
                    )
                    
                    modelContext.insert(paymentMethod)
                }
                
                // Mark onboarding as complete
                user.hasCompletedOnboarding = true
                
                try modelContext.save()
            }
        } catch {
            print("Error completing onboarding: \(error)")
        }
        
        // Mark onboarding as complete in auth state
        withAnimation {
            authState.needsOnboarding = false
        }
    }
}

#Preview {
    OnboardingContainerView()
        .environmentObject(AppAuthState())
}
