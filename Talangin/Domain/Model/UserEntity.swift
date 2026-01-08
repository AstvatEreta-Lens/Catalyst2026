//
//  UserEntity.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 07/01/26.
//


import SwiftData
import Foundation

@Model
final class UserEntity {

    // MARK: - Identity
    @Attribute(.unique)
    var appleUserId: String

    // MARK: - Profile Info
    var fullName: String?
    var email: String?
    var phoneNumber: String?

    // MARK: - Photo
    var profilePhotoData: Data?   // simpan sebagai Data (JPEG/PNG)

    // MARK: - Relationships
    @Relationship(deleteRule: .cascade)
    var paymentMethods: [PaymentMethodEntity] = []

    // MARK: - Metadata
    var createdAt: Date
    var updatedAt: Date

    init(
        appleUserId: String,
        fullName: String? = nil,
        email: String? = nil,
        phoneNumber: String? = nil,
        profilePhotoData: Data? = nil
    ) {
        self.appleUserId = appleUserId
        self.fullName = fullName
        self.email = email
        self.phoneNumber = phoneNumber
        self.profilePhotoData = profilePhotoData
        self.createdAt = .now
        self.updatedAt = .now
    }
}
