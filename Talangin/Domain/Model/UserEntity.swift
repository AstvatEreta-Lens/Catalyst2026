//
//  UserEntity.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 07/01/26.
//  Updated by Rifqi Rahman on 19/01/26.
//
//  SwiftData model representing a user in the Talangin app.
//
//  BACKEND DEVELOPER NOTES:
//  -------------------------
//  User Data Model:
//  - appleUserId: Unique identifier from Sign in with Apple
//  - fullName: Display name shown to other users
//  - email: User's email (only provided on first Apple sign-in)
//  - phoneNumber: Optional phone number
//  - profilePhotoData: User's profile photo stored as binary data
//  - hasCompletedOnboarding: Whether user has completed profile setup
//
//  CloudKit Sync:
//  - This model should sync across user's devices
//  - Use CKRecord for cloud backup
//  - Handle merge conflicts for concurrent updates
//
//  Privacy Considerations:
//  - Email may be private relay address from Apple
//  - Profile photos should be compressed before storage
//  - Consider GDPR compliance for data export/deletion
//

import SwiftData
import Foundation


@Model
final class UserEntity {

    // MARK: - Identity
    var appleUserId: String?

    // MARK: - Profile Info
    
    /// User's display name visible to other users
    var fullName: String?
    
    /// User's email address (may be private relay)
    var email: String?
    
    /// Optional phone number
    var phoneNumber: String?

    // MARK: - Photo
    
    /// Profile photo stored as binary data (JPEG/PNG)
    var profilePhotoData: Data?

    // MARK: - Onboarding Status
    
    /// Whether the user has completed the onboarding flow
    /// BACKEND NOTE: Check this flag to determine if user needs onboarding
    var hasCompletedOnboarding: Bool

    // MARK: - Relationships
    
    /// User's payment methods for receiving transfers
    @Relationship(deleteRule: .cascade, inverse: \PaymentMethodEntity.user)
    var paymentMethods: [PaymentMethodEntity]? = []
    
    @Relationship(deleteRule: .nullify, inverse: \SplitParticipantEntity.user)
    var splitParticipants: [SplitParticipantEntity]? = []

    // MARK: - Metadata
    var createdAt: Date?
    var updatedAt: Date?

    init(
        appleUserId: String,
        fullName: String? = nil,
        email: String? = nil,
        phoneNumber: String? = nil,
        profilePhotoData: Data? = nil,
        hasCompletedOnboarding: Bool = false
    ) {
        self.appleUserId = appleUserId
        self.fullName = fullName
        self.email = email
        self.phoneNumber = phoneNumber
        self.profilePhotoData = profilePhotoData
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.createdAt = .now
        self.updatedAt = .now
    }
}
