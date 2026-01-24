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
        print("➕ GroupRepository: Creating group '\(name)'...")
        print("   👥 Members count: \(members.count)")
        
        let group = GroupEntity(
            name: name,
            groupDescription: description,
            members: members
        )
        
        do {
            modelContext.insert(group)
            try modelContext.save()
            print("✅ GroupRepository: Group '\(name)' created successfully")
            print("   🆔 Group ID: \(group.id?.uuidString ?? "nil")")
            return group
        } catch {
            print("❌ GroupRepository: Failed to create group - \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Read
    func fetchAllGroups() throws -> [GroupEntity] {
        print("🔍 GroupRepository: Fetching all groups...")
        
        do {
            let descriptor = FetchDescriptor<GroupEntity>(
                sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
            )
            let groups = try modelContext.fetch(descriptor)
            print("✅ GroupRepository: Fetched \(groups.count) groups")
            return groups
        } catch {
            print("❌ GroupRepository: Failed to fetch groups - \(error.localizedDescription)")
            throw error
        }
    }
    
    func fetchGroup(byId id: UUID) throws -> GroupEntity? {
        print("🔍 GroupRepository: Fetching group by ID: \(id.uuidString)")
        
        do {
            let descriptor = FetchDescriptor<GroupEntity>(
                predicate: #Predicate { $0.id == id }
            )
            let group = try modelContext.fetch(descriptor).first
            
            if let group = group {
                print("✅ GroupRepository: Found group '\(group.name ?? "Untitled")'")
            } else {
                print("⚠️ GroupRepository: No group found with ID: \(id.uuidString)")
            }
            
            return group
        } catch {
            print("❌ GroupRepository: Failed to fetch group - \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Update
    func updateGroup(_ group: GroupEntity) throws {
        print("✏️ GroupRepository: Updating group '\(group.name ?? "Untitled")'...")
        
        do {
            group.updatedAt = .now
            try modelContext.save()
            print("✅ GroupRepository: Group updated successfully")
        } catch {
            print("❌ GroupRepository: Failed to update group - \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Delete
    func deleteGroup(_ group: GroupEntity) throws {
        let groupName = group.name ?? "Untitled"
        let groupId = group.id?.uuidString ?? "nil"
        print("🗑️ GroupRepository: Deleting group '\(groupName)' (ID: \(groupId))...")
        
        do {
            modelContext.delete(group)
            try modelContext.save()
            print("✅ GroupRepository: Group '\(groupName)' deleted successfully")
        } catch {
            print("❌ GroupRepository: Failed to delete group - \(error.localizedDescription)")
            throw error
        }
    }
}
