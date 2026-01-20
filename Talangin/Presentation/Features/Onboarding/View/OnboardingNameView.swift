//
//  OnboardingNameView.swift
//  Talangin
//
//  Created by Rifqi Rahman on 19/01/26.
//
//  First step of user onboarding: collecting the display name.
//  This name will be shown to other users in expense sharing.
//
//  BACKEND DEVELOPER NOTES:
//  -------------------------
//  User Profile Setup:
//  1. This view collects the user's display name for their profile
//  2. The display name is shown to friends when splitting expenses
//  3. Should be stored in UserEntity.fullName
//
//  API Integration:
//  - PATCH /users/profile { displayName } -> Update user profile
//  - Consider syncing with CloudKit for cross-device consistency
//  - Validate name is not empty and has reasonable length (2-50 chars)
//
//  SwiftData Integration:
//  - Update UserEntity.fullName with the entered value
//  - Save context after update
//

import SwiftUI

struct OnboardingNameView: View {
    
    // MARK: - Properties
    @State private var displayName: String = ""
    @FocusState private var isNameFocused: Bool
    
    /// Callback when user completes this step
    let onContinue: (String) -> Void
    
    // MARK: - Computed Properties
    private var isValidName: Bool {
        displayName.trimmingCharacters(in: .whitespaces).count >= 2
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // MARK: - Background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            // MARK: - Gradient Header
            gradientHeader
            
            // MARK: - Content
            VStack(spacing: 0) {
                // Spacer for gradient area
                Color.clear
                    .frame(height: 200)
                
                // Card Content
                cardContent
            }
        }
    }
    
    // MARK: - Gradient Header
    private var gradientHeader: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color("#3a5a8a"),
                    Color("#4a7a9a"),
                    Color("#5a9aaa")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Decorative Element
            VStack {
                Spacer()
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.bottom, AppSpacing.xxxl)
            }
        }
        .frame(height: 280)
        .ignoresSafeArea(edges: .top)
    }
    
    // MARK: - Card Content
    private var cardContent: some View {
        VStack(spacing: AppSpacing.xl) {
            // MARK: - Header
            headerSection
            
            // MARK: - Name Input
            nameInputSection
            
            Spacer()
            
            // MARK: - Continue Button
            continueButton
        }
        .padding(.horizontal, AppSpacing.xl)
        .padding(.top, AppSpacing.xl)
        .padding(.bottom, AppSpacing.xxxl)
        .background(
            RoundedCorner(radius: 24, corners: [.topLeft, .topRight])
                .fill(Color(.systemBackground))
        )
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("What should we call you?")
                .font(.Title1)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("This name will be visible to your friends when splitting expenses")
                .font(.Body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Name Input Section
    private var nameInputSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Display Name")
                .font(.Subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            OnboardingTextField(
                placeholder: "e.g., John Doe",
                text: $displayName,
                showClearButton: true
            )
            .focused($isNameFocused)
            
            // Helper text
            if !displayName.isEmpty && !isValidName {
                Text("Name must be at least 2 characters")
                    .font(.Caption)
                    .foregroundColor(AppColors.error)
            }
        }
    }
    
    // MARK: - Continue Button
    private var continueButton: some View {
        Button {
            onContinue(displayName.trimmingCharacters(in: .whitespaces))
        } label: {
            Text("Continue")
                .font(.Headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isValidName ? AppColors.primary : AppColors.gray02)
                )
        }
        .disabled(!isValidName)
    }
}

#Preview {
    OnboardingNameView { name in
        print("Name entered: \(name)")
    }
}
