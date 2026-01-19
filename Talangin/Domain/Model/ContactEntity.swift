//
//  ContactEntity.swift
//  Talangin
//
//  Created by Rifqi Rahman on 19/01/26.
//
//  Contact/Friend entity model for managing user's friends list.
//
//  BACKEND DEVELOPER NOTES:
//  -------------------------
//  This model represents a friend/contact in the split-bill app.
//  
//  Required fields for API integration:
//  - id: Unique identifier (UUID or server-generated ID)
//  - fullName: Display name of the contact
//  - email: Email address (used for identification and display)
//  - profilePhotoURL: Optional URL for profile photo from server
//  - paymentMethods: Array of payment methods this contact has shared
//  - sharedGroups: Array of group IDs that both user and contact belong to
//  
//  API Endpoints to implement:
//  - GET /contacts - Fetch all contacts for current user
//  - GET /contacts/{id} - Fetch single contact details
//  - POST /contacts - Add new contact (by email/phone lookup)
//  - DELETE /contacts/{id} - Remove contact from friends list
//  - GET /contacts/{id}/payment-methods - Get contact's shared payment methods
//
//  CloudKit Integration:
//  - Consider using CKRecord with "Contact" recordType
//  - Use CKReference for relationships with UserEntity and GroupEntity
//

import SwiftData
import Foundation

@Model
final class ContactEntity {
    
    // MARK: - Identity
    @Attribute(.unique)
    var id: UUID
    
    // MARK: - Profile Info
    var fullName: String
    var email: String
    var phoneNumber: String?
    
    // MARK: - Photo
    /// Profile photo data stored locally (cached from server)
    /// BACKEND NOTE: Replace with profilePhotoURL for server integration
    var profilePhotoData: Data?
    
    // MARK: - Relationships
    /// Payment methods this contact has shared with the user
    /// BACKEND NOTE: This should be fetched from server, not stored locally
    @Relationship(deleteRule: .cascade)
    var paymentMethods: [ContactPaymentMethod] = []
    
    /// Groups that both the user and this contact belong to
    /// BACKEND NOTE: Use group IDs and fetch from server
    var sharedGroupIds: [UUID] = []
    
    // MARK: - Metadata
    var createdAt: Date
    var updatedAt: Date
    
    // MARK: - Computed Properties
    
    /// Returns initials from fullName (e.g., "John Doe" -> "JD")
    var initials: String {
        let components = fullName.split(separator: " ")
        let initials = components.prefix(2).compactMap { $0.first }
        return String(initials).uppercased()
    }
    
    /// Checks if contact has a profile photo
    var hasProfilePhoto: Bool {
        profilePhotoData != nil
    }
    
    // MARK: - Initializer
    init(
        id: UUID = UUID(),
        fullName: String,
        email: String,
        phoneNumber: String? = nil,
        profilePhotoData: Data? = nil,
        sharedGroupIds: [UUID] = []
    ) {
        self.id = id
        self.fullName = fullName
        self.email = email
        self.phoneNumber = phoneNumber
        self.profilePhotoData = profilePhotoData
        self.sharedGroupIds = sharedGroupIds
        self.createdAt = .now
        self.updatedAt = .now
    }
}

// MARK: - Contact Payment Method
/// Represents a payment method shared by a contact
/// BACKEND NOTE: This is a simplified version for display purposes.
/// In production, fetch from server with limited fields (no sensitive data).

@Model
final class ContactPaymentMethod {
    
    @Attribute(.unique)
    var id: UUID
    
    var providerName: String  // e.g., "BCA", "GoPay"
    var destination: String   // Account number (may be partially masked)
    var holderName: String
    var isPrimary: Bool
    
    @Relationship(inverse: \ContactEntity.paymentMethods)
    var contact: ContactEntity?
    
    init(
        providerName: String,
        destination: String,
        holderName: String,
        isPrimary: Bool = false,
        contact: ContactEntity? = nil
    ) {
        self.id = UUID()
        self.providerName = providerName
        self.destination = destination
        self.holderName = holderName
        self.isPrimary = isPrimary
        self.contact = contact
    }
}

// MARK: - Mock Data for Development
/// BACKEND NOTE: Remove this extension before production release.
/// This provides sample data for UI development and testing.

extension ContactEntity {
    
    static var mockContacts: [ContactEntity] {
        [
            ContactEntity(
                fullName: "Andi Sandika",
                email: "andi.sandika@gmail.com"
            ),
            ContactEntity(
                fullName: "John Dioe",
                email: "john.dioe@gmail.com"
            ),
            ContactEntity(
                fullName: "Sari Yulia",
                email: "saryulia@gmail.com"
            )
        ]
    }
    
    /// Creates a mock contact with payment methods for preview/testing
    static func mockContactWithPayments() -> ContactEntity {
        let contact = ContactEntity(
            fullName: "Sari Yulia",
            email: "saryulia@gmail.com"
        )
        
        let payment1 = ContactPaymentMethod(
            providerName: "BCA",
            destination: "120-12038-00500",
            holderName: "Sari Yulia",
            isPrimary: true,
            contact: contact
        )
        
        let payment2 = ContactPaymentMethod(
            providerName: "GoPay",
            destination: "081234568887",
            holderName: "Sari Yulia",
            isPrimary: false,
            contact: contact
        )
        
        contact.paymentMethods = [payment1, payment2]
        contact.sharedGroupIds = [UUID(), UUID()] // Mock group IDs
        
        return contact
    }
}
