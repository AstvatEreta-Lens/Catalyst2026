//
//  Login.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 01/01/26.
//
import SwiftUI
import AuthenticationServices
import SwiftData

struct SignInView: View {

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var authState: AppAuthState

    @StateObject private var viewModel = AuthViewModel()


    var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.lg) {

                header
                form
                loginButton

                Divider()

                appleSignIn

                Spacer()

                footer
            }
            .padding(.horizontal, AppSpacing.lg)
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
        }
        .onAppear {
            // inject real context once view appears
            viewModel.injectContext(modelContext)
        }
    }
}

private extension SignInView {
    var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Talangin")
                .font(.largeTitle)
                .bold()

            Text("Silakan masuk untuk melanjutkan aplikasi.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, AppSpacing.xl)
    }
}

private extension SignInView {
    var form: some View {
        VStack(spacing: AppSpacing.sm) {
            AuthTextField(
                image: AppIcons.Auth.email,
                placeholder: "Email",
                text: $viewModel.email
            )

            AuthTextField(
                image: AppIcons.Auth.password,
                placeholder: "Password",
                text: $viewModel.password,
                isSecure: true
            )

            Button("Forgot Password?") {
                // TODO
            }
            .font(.footnote)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

private extension SignInView {
    var loginButton: some View {
        Button {
            viewModel.loginWithEmail()
        } label: {
            Text("Login")
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.accentColor)
                .cornerRadius(12)
        }
    }
}

private extension SignInView {
    var appleSignIn: some View {
        SignInWithAppleButton(
            .signIn,
            onRequest: viewModel.configureAppleRequest,
            onCompletion: { result in
                viewModel.handleAppleResult(result) {
                    authState.isAuthenticated = true
                }
            }
        )
        .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
        .frame(height: 50)
        .cornerRadius(12)
    }
}


private extension SignInView {
    var footer: some View {
        HStack {
            Text("Don't have an account?")
                .font(.footnote)
                .foregroundColor(.secondary)

            Button("Sign Up") {
                viewModel.showSignUp = true
            }
            .font(.footnote.bold())
        }
        .navigationDestination(isPresented: $viewModel.showSignUp) {
            SignUp()
        }
        .padding(.bottom, AppSpacing.md)
    }
}

#Preview {
    SignInView()
        .environmentObject(AppAuthState())
}
