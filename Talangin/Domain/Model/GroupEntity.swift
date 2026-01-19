//
//  GroupEntity.swift
//  Talangin
//
//  Created by Rifqi Rahman on 19/01/26.
//
//  Group entity model for managing expense sharing groups.
//
//  BACKEND DEVELOPER NOTES:
//  -------------------------
//  This model represents a group for splitting bills/expenses.
//  
//  Required fields for API integration:
//  - id: Unique identifier (UUID or server-generated ID)
//  - name: Display name of the group
//  - iconName: SF Symbol name for group icon (or custom icon URL)
//  - iconBackgroundColor: Hex color string for icon background
//  - members: Array of member user IDs
//  - createdBy: User ID of group creator
//  - totalExpenses: Calculated total of all expenses in group
//  - userBalance: Current user's balance in this group
//  
//  API Endpoints to implement:
//  - GET /groups - Fetch all groups for current user
//  - GET /groups/{id} - Fetch single group details with members
//  - POST /groups - Create new group
//  - PUT /groups/{id} - Update group info
//  - DELETE /groups/{id} - Delete group (creator only)
//  - POST /groups/{id}/members - Add member to group
//  - DELETE /groups/{id}/members/{userId} - Remove member from group
//
//  CloudKit Integration:
//  - Consider using CKRecord with "Group" recordType
//  - Use CKReference array for member relationships
//  - Store icon as CKAsset if using custom images
//

import SwiftData
import Foundation
import SwiftUI

@Model
final class GroupEntity {
    
    // MARK: - Identity
    @Attribute(.unique)
    var id: UUID
    
    // MARK: - Group Info
    var name: String
    
    /// SF Symbol name for group icon
    /// BACKEND NOTE: Could be extended to support custom image URLs
    var iconName: String
    
    /// Hex color string for icon background (e.g., "#E8F5E9")
    var iconBackgroundColorHex: String
    
    // MARK: - Photo (Optional custom group image)
    /// Custom group photo data
    /// BACKEND NOTE: Consider storing as URL for server images
    var groupPhotoData: Data?
    
    // MARK: - Members
    /// Array of member user IDs
    /// BACKEND NOTE: Fetch full member details from server when needed
    var memberIds: [String] = []
    
    /// Creator user ID
    var createdBy: String
    
    // MARK: - Metadata
    var createdAt: Date
    var updatedAt: Date
    
    // MARK: - Computed Properties
    
    /// Returns the number of members in the group
    var memberCount: Int {
        memberIds.count
    }
    
    /// Checks if group has a custom photo
    var hasCustomPhoto: Bool {
        groupPhotoData != nil
    }
    
    /// Converts hex color string to SwiftUI Color
    var iconBackgroundColor: Color {
        Color(hex: iconBackgroundColorHex) ?? Color.gray.opacity(0.2)
    }
    
    // MARK: - Initializer
    init(
        id: UUID = UUID(),
        name: String,
        iconName: String = "person.3.fill",
        iconBackgroundColorHex: String = "#E8F5E9",
        groupPhotoData: Data? = nil,
        memberIds: [String] = [],
        createdBy: String
    ) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.iconBackgroundColorHex = iconBackgroundColorHex
        self.groupPhotoData = groupPhotoData
        self.memberIds = memberIds
        self.createdBy = createdBy
        self.createdAt = .now
        self.updatedAt = .now
    }
}

// MARK: - Color Extension for Hex Support
/// Helper extension to create Color from hex string

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }
        
        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Mock Data for Development
/// BACKEND NOTE: Remove this extension before production release.
/// This provides sample data for UI development and testing.

extension GroupEntity {
    
    static var mockGroups: [GroupEntity] {
        [
            GroupEntity(
                name: "Arisan Ibu Gang 2",
                iconName: "hand.raised.fingers.spread.fill",
                iconBackgroundColorHex: "#FFF3E0",
                createdBy: "user1"
            ),
            GroupEntity(
                name: "Merbabu - Talangin",
                iconName: "mountain.2.fill",
                iconBackgroundColorHex: "#E8F5E9",
                createdBy: "user1"
            ),
            GroupEntity(
                name: "My Family",
                iconName: "figure.2.and.child.holdinghands",
                iconBackgroundColorHex: "#E3F2FD",
                createdBy: "user1"
            ),
            GroupEntity(
                name: "Trip To Bromo",
                iconName: "car.fill",
                iconBackgroundColorHex: "#FCE4EC",
                createdBy: "user1"
            )
        ]
    }
    
    /// Creates a mock group with members for preview/testing
    static func mockGroupWithMembers() -> GroupEntity {
        let group = GroupEntity(
            name: "Trip To Bromo",
            iconName: "car.fill",
            iconBackgroundColorHex: "#FCE4EC",
            memberIds: ["user1", "user2", "user3", "user4"],
            createdBy: "user1"
        )
        return group
    }
}
