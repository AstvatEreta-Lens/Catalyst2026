//
//  GroupEntity.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 12/01/26.
//

import SwiftData
import Foundation

@Model
final class GroupEntity {
    
    // MARK: - uniq id
    var id: UUID?
    
    // MARK: - info grup
    var name: String?
    var groupDescription: String?
    
    // MARK: - Relationships
    @Relationship(deleteRule: .nullify, inverse: \FriendEntity.groups)
    var members: [FriendEntity]? = []
    
    // Inverse entity
    @Relationship(deleteRule: .cascade, inverse: \ExpenseEntity.group)
    var expenses: [ExpenseEntity]? = []
    
    // MARK: - Metadata
    var createdAt: Date?
    var updatedAt: Date?
    
    // MARK: - Hitung jumlah member
    var memberCount: Int {
        members?.count ?? 0
    }
    
    // MARK: - initial abatar
    var avatarInitials: String {
        let components = (name ?? "Untitled").components(separatedBy: " ")
        let initials = components.compactMap { $0.first }.prefix(2)
        return String(initials).uppercased()
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        groupDescription: String? = nil,
        members: [FriendEntity] = []
    ) {
        self.id = id
        self.name = name
        self.groupDescription = groupDescription
        self.members = members
        self.createdAt = .now
        self.updatedAt = .now
    }
}
