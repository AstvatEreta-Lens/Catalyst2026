//
//  Login.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 01/01/26.
//
import SwiftUI
import AuthenticationServices

struct SignIn: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var email = ""
    @State private var password = ""
    @State private var navigateToSignUp = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 25) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    
                    Text("Talangin")
                        .font(.largeTitle)
                        .bold()
                    
                    Text("Silakan masuk untuk melanjutkan aplikasi.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 40)
                
                // Form Fields
                VStack(spacing: 15) {
                    AuthTextField(image: "envelope", placeholder: "Email", text: $email)
                    AuthTextField(image: "lock", placeholder: "Password", text: $password, isSecure: true)
                    
                    Button(action: { /* Forgot Password action */ }) {
                        Text("Forgot Password?")
                            .font(.footnote)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                
                // Main Login Button
                Button(action: {
                    // Aksi login
                }) {
                    Text("Login")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.accentColor)
                        .cornerRadius(12)
                }
                .padding(.top, 10)
                
                // Divider "Or Continue With"
                HStack {
                    Rectangle().frame(height: 1).foregroundColor(Color(.systemGray5))
                    Text("OR")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                    Rectangle().frame(height: 1).foregroundColor(Color(.systemGray5))
                }
                .padding(.vertical)
                
                // Apple Sign In
                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    switch result {
                    case .success(let authorization):
                        handleSuccessfulLogin(with: authorization)
                    case .failure(let error):
                        handleLoginError(with: error)
                    }
                }
                .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                .frame(height: 50)
                .cornerRadius(12)
                
                Spacer()
                
                // Footer
                HStack {
                    Text("Don't have an account?")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    Button("Sign Up") {
                        navigateToSignUp = true
                    }
                    .font(.footnote.bold())
                }
                .navigationDestination(isPresented: $navigateToSignUp) {
                    SignUp()
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 25)
            .navigationBarHidden(true)
        }
       
    }
    
   
    // MARK: - Logic Handlers
    private func handleSuccessfulLogin(with authorization: ASAuthorization) {
        // ... kode handle login Anda
    }
    
    private func handleLoginError(with error: Error) {
        print("Error: \(error.localizedDescription)")
    }
}

#Preview {
    SignIn()
}
