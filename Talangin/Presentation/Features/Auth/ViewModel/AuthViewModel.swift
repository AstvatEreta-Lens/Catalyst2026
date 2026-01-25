//
//  AuthViewModel.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 04/01/26.
//
import SwiftData
import AuthenticationServices
import Combine

@MainActor
final class AuthViewModel: NSObject, ObservableObject {

    // MARK: - Dependencies
    private var userRepository: UserRepositoryProtocol?
    @Published var isAuthenticated: Bool = false

    // MARK: - UI State
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    @Published var email: String = ""
    @Published var password: String = ""
    @Published var showSignUp: Bool = false

    // MARK: - Injection
    func injectContext(_ context: ModelContext) {
        self.userRepository = UserRepository(context: context)
    }

    // MARK: - Email Login
    func loginWithEmail() {

        print("Login with email:", email)
    }
    
    func logout() {
            KeychainService.delete(for: "appleUserID")
            isAuthenticated = false
        }

    // MARK: - Apple Sign In
    func configureAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
    }
    

    func handleAppleResult(
        _ result: Result<ASAuthorization, Error>,
        onSuccess: @escaping () -> Void
    ) {
        switch result {
        case .success(let authorization):
            handleAppleSuccess(authorization, onSuccess: onSuccess)
        case .failure(let error):
            print("error: \(error.localizedDescription)")
        }
    }

    private func handleAppleSuccess(
        _ authorization: ASAuthorization,
        onSuccess: @escaping () -> Void
    ) {
        guard
            let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let repository = userRepository
        else {
            errorMessage = "Invalid authentication state."
            return
        }

        let appleUserId = credential.user
        let email = credential.email

        let fullName = [
            credential.fullName?.givenName,
            credential.fullName?.familyName
        ].compactMap { $0 }.joined(separator: " ")

        let resolvedName = fullName.isEmpty ? nil : fullName

        isLoading = true

        do {
            KeychainService.save(appleUserId, for: "appleUserID")

            try repository.upsertUser(
                appleUserId: appleUserId,
                fullName: resolvedName,
                email: email
            )

            isLoading = false
            onSuccess()

        } catch {
            isLoading = false
            errorMessage = "Failed to persist user data."
        }
    }
}
