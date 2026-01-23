//
//  GroupRepository.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 16/01/26.
//

import SwiftData
import Foundation

@MainActor
final class GroupRepository {
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Create
    func createGroup(
        name: String,
        description: String? = nil,
        members: [FriendEntity]
    ) throws -> GroupEntity {
        let group = GroupEntity(
            name: name,
            groupDescription: description,
            members: members
        )
        
        modelContext.insert(group)
        try modelContext.save()
        
        return group
    }
    
    // MARK: - Read
    func fetchAllGroups() throws -> [GroupEntity] {
        let descriptor = FetchDescriptor<GroupEntity>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    func fetchGroup(byId id: UUID) throws -> GroupEntity? {
        let descriptor = FetchDescriptor<GroupEntity>(
            predicate: #Predicate { $0.id == id }
        )
        return try modelContext.fetch(descriptor).first
    }
    
    // MARK: - Update
    func updateGroup(_ group: GroupEntity) throws {
        group.updatedAt = .now
        try modelContext.save()
    }
    
    // MARK: - Delete
    func deleteGroup(_ group: GroupEntity) throws {
        modelContext.delete(group)
        try modelContext.save()
    }
}
