//
//  ProfileViewModel.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 06/01/26.
//
//  ViewModel for Profile feature handling user data, preferences, and settings.
//  Updated: Added isPremium property for subscription state.
//
import Foundation
import SwiftData
import Combine
import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {

    @Published private(set) var user: UserEntity?
    @Published var notificationsEnabled: Bool = true
    @Published var selectedTheme: String = "System (default)"
    @Published var selectedLanguage: String = "English"
    
    // MARK: - Subscription State
    /// BACKEND NOTE: Replace with actual subscription status from StoreKit/server
    @Published var isPremium: Bool = false
    
    // MARK: - Error Handling
    @Published var errorMessage: String?
    @Published var showError: Bool = false

    private var repository: UserRepositoryProtocol?
    
    // MARK: - Constants
    static let themeOptions = ["System (default)", "Light", "Dark"]
    static let languageOptions = ["English", "Indonesian"]
    static let appVersion = "1.00"

    init() {}

    func injectContext(_ context: ModelContext) {
        self.repository = UserRepository(context: context)
        loadUser()
    }

    // MARK: - Load
    func loadUser() {
        guard let repository else { return }

        do {
            self.user = try repository.getCurrentUser()
            errorMessage = nil
        } catch {
            errorMessage = "Failed to load user: \(error.localizedDescription)"
            showError = true
        }
    }

    // MARK: - Computed (safe for View)
    var userId: String { user?.appleUserId ?? "-" }
    var fullName: String { user?.fullName ?? "-" }
    var email: String { user?.email ?? "-" }
    var phoneNumber: String? { user?.phoneNumber }
    var paymentMethods: [PaymentMethodEntity] { user?.paymentMethods ?? [] }

    var profilePhotoData: Data? {
        user?.profilePhotoData
    }

    var createdAtFormatted: String {
        guard let date = user?.createdAt else { return "-" }
        return date.formatted(date: .long, time: .omitted)
    }

    // MARK: - Update
    
    /// Updates user profile information (name, email, phone)
    func updateProfile(name: String, email: String, phone: String?) {
        guard let user = user else {
            errorMessage = "No user found to update"
            showError = true
            return
        }
        
        user.fullName = name
        user.email = email
        user.phoneNumber = phone
        user.updatedAt = .now
        
        save()
    }
    
    func updatePhone(_ phone: String?) {
        repository?.updatePhoneNumber(phone)
        save()
    }

    func updatePhoto(_ data: Data) {
        repository?.updateProfilePhoto(data)
        save()
    }

    private func save() {
        do {
            try repository?.save()
            loadUser()
            errorMessage = nil
        } catch {
            errorMessage = "Failed to save changes: \(error.localizedDescription)"
            showError = true
        }
    }
}
