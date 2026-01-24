//
//  FriendEntity.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 12/01/26.
//

import SwiftData
import Foundation

@Model
final class FriendEntity {
    
    // MARK: - Identitas
    var id: UUID?
    
    // MARK: - Priflie
    var userId: String?
    var fullName: String?
    var email: String?
    var phoneNumber: String?
    
    // MARK: - photo profile
    var profilePhotoData: Data?
    
    // MARK: - Relationships
    @Relationship(deleteRule: .nullify)
    var groups: [GroupEntity]? = []
    
    @Relationship(inverse: \SplitParticipantEntity.friend)
    var participantDetails: [SplitParticipantEntity]? = []
    
    // MARK: - Metadata
    var createdAt: Date?
    
    // MARK: - iniisal avatar
    var avatarInitials: String {
        let components = (fullName ?? "User").components(separatedBy: " ")
        let initials = components.compactMap { $0.first }.prefix(2)
        return String(initials).uppercased()
    }
    
    init(
        id: UUID = UUID(),
        userId: String,
        fullName: String,
        email: String? = nil,
        phoneNumber: String? = nil,
        profilePhotoData: Data? = nil
    ) {
        self.id = id
        self.userId = userId
        self.fullName = fullName
        self.email = email
        self.phoneNumber = phoneNumber
        self.profilePhotoData = profilePhotoData
        self.createdAt = .now
    }
}
