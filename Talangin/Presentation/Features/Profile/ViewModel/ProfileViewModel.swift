//
//  ProfileViewModel.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 06/01/26.
//
import Foundation
import SwiftData
import Combine
import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {

    @Published private(set) var user: UserEntity?

    private var repository: UserRepositoryProtocol?


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
        } catch {
            print("Failed to load user:", error)
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
        } catch {
            print("Save failed:", error)
        }
    }
}
