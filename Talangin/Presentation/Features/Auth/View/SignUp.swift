//
//  SignUp.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 02/01/26.
//  Updated by Rifqi Rahman on 19/01/26.
//
//  Sign-up screen with gradient header and card-based form layout.
//  Collects user registration information.
//
//  BACKEND DEVELOPER NOTES:
//  -------------------------
//  Registration Flow:
//  1. Validate all fields client-side before submission:
//     - Email format validation
//     - Password strength (min 8 chars, uppercase, number, special char)
//     - Password confirmation match
//     - Full name not empty
//
//  2. Submit registration to backend:
//     - POST /auth/register { fullName, email, password }
//     - Return { token, user } on success
//     - Return { error, message } on failure (e.g., email already exists)
//
//  3. After successful registration:
//     - Store auth token in Keychain
//     - Navigate to onboarding flow
//     - Send verification email if required
//
//  4. Error handling:
//     - Display specific error messages (email taken, weak password, etc.)
//     - Handle network errors gracefully
//

import SwiftUI

struct SignUpView: View {
    
    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authState: AppAuthState
    
    // MARK: - Form State
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showPassword: Bool = false
    @State private var showConfirmPassword: Bool = false
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var showError: Bool = false
    
    // MARK: - Validation
    private var isFormValid: Bool {
        !fullName.isEmpty &&
        !email.isEmpty &&
        email.contains("@") &&
        !password.isEmpty &&
        password.count >= 6 &&
        password == confirmPassword
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // MARK: - Background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            // MARK: - Gradient Background
            gradientBackground
            
            // MARK: - White Card Content
            ScrollView {
                VStack(spacing: 0) {
                    // Spacer for gradient area
                    Color.clear
                        .frame(height: 200)
                    
                    // Card Content
                    cardContent
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "An error occurred")
        }
    }
    
    
    // MARK: - Card Content
    private var cardContent: some View {
        VStack(spacing: AppSpacing.lg) {
            // MARK: - Header Text
            headerSection
            
            // MARK: - Form Fields
            formSection
            
            // MARK: - Sign Up Button
            signUpButton
            
            Spacer(minLength: AppSpacing.xl)
            
            // MARK: - Footer
            footerSection
        }
        .padding(.horizontal, AppSpacing.xl)
        .padding(.top, AppSpacing.xl)
        .padding(.bottom, AppSpacing.lg)
        .background(
            RoundedCorner(radius: 24, corners: [.topLeft, .topRight])
                .fill(Color(.systemBackground))
        )
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Create an Account")
                .font(.Title1)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("Sign up to start managing your shared expenses more transparently")
                .font(.Subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Form Section
    private var formSection: some View {
        VStack(spacing: AppSpacing.md) {
            // Full Name
            OnboardingTextField(
                placeholder: "Full Name",
                text: $fullName,
                showClearButton: true
            )
            
            // Email
            OnboardingTextField(
                placeholder: "Email",
                text: $email,
                keyboardType: .emailAddress,
                showClearButton: true
            )
            
            // Password
            OnboardingTextField(
                placeholder: "Password",
                text: $password,
                isSecure: !showPassword,
                showVisibilityToggle: true,
                isPasswordVisible: $showPassword
            )
            
            // Confirm Password
            OnboardingTextField(
                placeholder: "Re-enter Password",
                text: $confirmPassword,
                isSecure: !showConfirmPassword,
                showVisibilityToggle: true,
                isPasswordVisible: $showConfirmPassword
            )
        }
    }
    
    // MARK: - Sign Up Button
    private var signUpButton: some View {
        Button {
            handleSignUp()
        } label: {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Sign Up")
                        .font(.Headline)
                        .fontWeight(.semibold)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isFormValid ? AppColors.primary : AppColors.gray02)
            )
        }
        .disabled(!isFormValid || isLoading)
    }
    
    // MARK: - Footer Section
    private var footerSection: some View {
        HStack(spacing: AppSpacing.xxs) {
            Text("Have an account?")
                .font(.Subheadline)
                .foregroundColor(.secondary)
            
            Button {
                dismiss()
            } label: {
                Text("Log In")
                    .font(.Subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.primary)
            }
        }
        .padding(.bottom, AppSpacing.md)
    }
    
    // MARK: - Actions
    
    private func handleSignUp() {
        // Validation
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            showError = true
            return
        }
        
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            showError = true
            return
        }
        
        isLoading = true
        
        // BACKEND NOTE: Implement actual registration API call here
        // Example:
        // Task {
        //     do {
        //         let response = try await authService.register(
        //             fullName: fullName,
        //             email: email,
        //             password: password
        //         )
        //         authState.isAuthenticated = true
        //         authState.needsOnboarding = true
        //     } catch {
        //         errorMessage = error.localizedDescription
        //         showError = true
        //     }
        //     isLoading = false
        // }
        
        // Mock registration for now
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            authState.isAuthenticated = true
            authState.needsOnboarding = true
        }
    }
}

#Preview {
    NavigationStack {
        SignUpView()
            .environmentObject(AppAuthState())
    }
}
