//
//  AppAuthState.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 06/01/26.
//


import Foundation
import Combine
import AuthenticationServices

@MainActor
final class AppAuthState: ObservableObject {

    @Published var isAuthenticated: Bool = false

    init() {
        restoreSession()
    }

    func restoreSession() {
        guard let appleUserID = KeychainService.load(for: "appleUserID") else {
            isAuthenticated = false
            return
        }

        let provider = ASAuthorizationAppleIDProvider()
        provider.getCredentialState(forUserID: appleUserID) { state, _ in
            DispatchQueue.main.async {
                self.isAuthenticated = (state == .authorized)
            }
        }
    }

    func logout() {
        KeychainService.delete(for: "appleUserID")
        isAuthenticated = false
    }
}
