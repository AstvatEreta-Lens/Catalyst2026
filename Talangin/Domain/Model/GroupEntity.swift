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
    var id: UUID?
    
    // MARK: - Group Info
    var name: String?
    var groupDescription: String?
    
    /// SF Symbol name for group icon
    var iconName: String?
    
    /// Hex color string for icon background
    var iconBackgroundColorHex: String?
    
    // MARK: - Photo
    var groupPhotoData: Data?
    
    // MARK: - Relationships
    @Relationship(deleteRule: .nullify, inverse: \FriendEntity.groups)
    var members: [FriendEntity]? = []
    
    @Relationship(deleteRule: .cascade, inverse: \ExpenseEntity.group)
    var expenses: [ExpenseEntity]? = []
    
    // MARK: - Metadata
    var createdAt: Date?
    var updatedAt: Date?
    
    // MARK: - Computed Properties
    var memberCount: Int {
        members?.count ?? 0
    }
    
    var avatarInitials: String {
        let components = (name ?? "Untitled").components(separatedBy: " ")
        let initials = components.compactMap { $0.first }.prefix(2)
        return String(initials).uppercased()
    }
    
    var iconBackgroundColor: Color {
        Color(hex: iconBackgroundColorHex ?? "#E8F5E9") ?? Color.gray.opacity(0.2)
    }
    
    // MARK: - Initializer
    init(
        id: UUID = UUID(),
        name: String,
        groupDescription: String? = nil,
        iconName: String = "person.3.fill",
        iconBackgroundColorHex: String = "#E8F5E9",
        members: [FriendEntity] = []
    ) {
        self.id = id
        self.name = name
        self.groupDescription = groupDescription
        self.iconName = iconName
        self.iconBackgroundColorHex = iconBackgroundColorHex
        self.members = members
        self.createdAt = .now
        self.updatedAt = .now
    }
}

// MARK: - Color Extension for Hex Support
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
extension GroupEntity {
    static var mockGroups: [GroupEntity] {
        [
            GroupEntity(
                name: "Trip To Bromo",
                groupDescription: "Patungan biaya bromo",
                iconName: "mountain.2.fill",
                iconBackgroundColorHex: "#E8F5E9"
            ),
            GroupEntity(
                name: "Dinner Team",
                groupDescription: "Makan malam mingguan",
                iconName: "fork.knife",
                iconBackgroundColorHex: "#FFF3E0"
            ),
            GroupEntity(
                name: "Kos-kosan",
                groupDescription: "Bayar listrik dan air",
                iconName: "house.fill",
                iconBackgroundColorHex: "#E3F2FD"
            )
        ]
    }
}
