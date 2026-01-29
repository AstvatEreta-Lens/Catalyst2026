//
//  SignIn.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 01/01/26.
//  Updated by Rifqi Rahman on 19/01/26.
//
//  Sign-in screen with gradient header and card-based form layout.
//  Supports email/password login and Sign in with Apple.
//
//  BACKEND DEVELOPER NOTES:
//  -------------------------
//  Authentication Flow:
//  1. Email/Password Login:
//     - Validate credentials against your auth service (Firebase Auth, custom API, etc.)
//     - On success, store user session token securely in Keychain
//     - On failure, display error message via viewModel.errorMessage
//
//  2. Sign in with Apple:
//     - Already implemented using ASAuthorizationAppleIDCredential
//     - credential.user is the unique Apple User ID
//     - Email and name are only provided on FIRST sign-in
//     - Store Apple User ID in Keychain for persistence
//
//  3. Forgot Password:
//     - Implement password reset flow (email link or code)
//     - Show confirmation that reset email was sent
//
//  API Endpoints to implement:
//  - POST /auth/login { email, password } -> { token, user }
//  - POST /auth/forgot-password { email } -> { success }
//

import SwiftUI
import AuthenticationServices
import SwiftData

struct SignInView: View {
    
    // MARK: - Environment
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var authState: AppAuthState
    
    // MARK: - ViewModel
    @StateObject private var viewModel = AuthViewModel()
    
    // MARK: - Local State
    @State private var showPassword = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // MARK: - Gradient Background
                gradientBackground
                    .ignoresSafeArea()
                
                // MARK: - Persistent Bottom Card
                VStack(spacing: 0) {
                    Spacer()
                    
                    cardContent
                        .background(
                            Color(.systemBackground)
                                .clipShape(RoundedCorner(radius: 24, corners: [.topLeft, .topRight]))
                                .shadow(color: .black.opacity(0.1), radius: 10, y: -5)
                        )
                }
                .ignoresSafeArea(edges: .bottom)
            }
            .navigationBarHidden(true)
            .alert(
                "Error",
                isPresented: Binding(
                    get: { viewModel.errorMessage != nil },
                    set: { _ in viewModel.errorMessage = nil }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .navigationDestination(isPresented: $viewModel.showSignUp) {
                SignUpView()
            }
        }
        .onAppear {
            viewModel.injectContext(modelContext)
        }
    }
    
    // MARK: - Card Content
    private var cardContent: some View {
        VStack(spacing: AppSpacing.lg) {
            // MARK: - Header Text
            headerSection
            
            
            // MARK: - Form Fields
            //            formSection
            
            //            // MARK: - Forgot Password
            //            forgotPasswordButton
            //
            //            // MARK: - Login Button
            //            loginButton
            //
            //            // MARK: - Divider
            //            orDivider
            
            // MARK: - Apple Sign In
            appleSignInButton
        }
        .padding(.horizontal, AppSpacing.xl)
        .padding(.top, 32)
        .padding(.bottom, 40) // Balance for safe area and look
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Welcome")
                .font(.appLargeTitle)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .lineSpacing(4)
            
            Text("Join us to track, split, and settle bills with ease")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Form Section
    private var formSection: some View {
        VStack(spacing: AppSpacing.md) {
            // Email Field
            OnboardingTextField(
                placeholder: "Email Address",
                text: $viewModel.email,
                keyboardType: .emailAddress,
                showClearButton: true
            )
            
            // Password Field
            OnboardingTextField(
                placeholder: "Password",
                text: $viewModel.password,
                isSecure: !showPassword,
                showVisibilityToggle: true,
                isPasswordVisible: $showPassword
            )
        }
    }
    
    // MARK: - Forgot Password Button
    private var forgotPasswordButton: some View {
        HStack {
            Spacer()
            Button {
                // BACKEND NOTE: Implement forgot password flow
            } label: {
                Text("Forgot password?")
                    .font(.Subheadline)
                    .foregroundColor(AppColors.primary)
            }
        }
    }
    
    // MARK: - Login Button
    private var loginButton: some View {
        Button {
            viewModel.loginWithEmail()
        } label: {
            Text("Log In")
                .font(.Headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppColors.primary)
                )
        }
        .disabled(viewModel.email.isEmpty || viewModel.password.isEmpty)
        .opacity(viewModel.email.isEmpty || viewModel.password.isEmpty ? 0.6 : 1)
    }
    
    // MARK: - Or Divider
    private var orDivider: some View {
        HStack {
            Rectangle()
                .fill(Color(.systemGray4))
                .frame(height: 1)
            
            Text("Or")
                .font(.Subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal, AppSpacing.sm)
            
            Rectangle()
                .fill(Color(.systemGray4))
                .frame(height: 1)
        }
    }
    
    // MARK: - Apple Sign In Button
    private var appleSignInButton: some View {
        SignInWithAppleButton(
            .signIn,
            onRequest: viewModel.configureAppleRequest,
            onCompletion: { result in
                viewModel.handleAppleResult(result) {
                    authState.isAuthenticated = true
                    authState.needsOnboarding = true
                }
            }
        )
        .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
        .frame(height: 50)
        .cornerRadius(12)
    }
    
    // MARK: - Footer Section
    private var footerSection: some View {
        HStack(spacing: AppSpacing.xxs) {
            Text("Don't have any account?")
                .font(.Subheadline)
                .foregroundColor(.secondary)
            
            Button {
                viewModel.showSignUp = true
            } label: {
                Text("Sign Up")
                    .font(.Subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.primary)
            }
        }
        .padding(.bottom, AppSpacing.md)
    }
}

#Preview {
    SignInView()
        .environmentObject(AppAuthState())
}
