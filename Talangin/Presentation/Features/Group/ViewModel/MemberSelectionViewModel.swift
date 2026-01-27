//
//  MemberSelectionViewModel.swift
//  Talangin
//
//  Created by Rifqi Rahman on 27/01/26.
//
//  ViewModel for selecting group members from friends list.
//  Reuses logic pattern from BeneficiarySelectionViewModel.
//

import SwiftUI
import SwiftData
import Observation

@MainActor
@Observable
final class MemberSelectionViewModel {
    
    struct SelectedMember: Identifiable, Equatable {
        let id: UUID
        let name: String
        let initials: String
    }
    
    // MARK: - State
    var friends: [FriendEntity] = []
    var selectedFriendIds: Set<UUID> = []
    var searchText: String = ""
    var newFriendName: String = ""
    
    // MARK: - Dependencies
    private let modelContext: ModelContext
    
    // MARK: - Computed Properties
    var filteredFriends: [FriendEntity] {
        if searchText.isEmpty {
            return friends
        }
        return friends.filter { friend in
            (friend.fullName ?? "").localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var allSelectedMembers: [SelectedMember] {
        selectedFriendIds.compactMap { friendId in
            guard let friend = friends.first(where: { $0.id == friendId }) else { return nil }
            return SelectedMember(
                id: friendId,
                name: friend.fullName ?? "Unknown",
                initials: friend.avatarInitials
            )
        }
    }
    
    // MARK: - Initialization
    init(modelContext: ModelContext, initialSelectedMembers: [FriendEntity] = []) {
        self.modelContext = modelContext
        
        // Initialize selected IDs from initial members
        for member in initialSelectedMembers {
            if let id = member.id {
                selectedFriendIds.insert(id)
            }
        }
        
        // Load friends from ModelContext
        loadFriends()
    }
    
    // MARK: - Data Loading
    private func loadFriends() {
        do {
            let descriptor = FetchDescriptor<FriendEntity>(
                sortBy: [SortDescriptor(\.fullName)]
            )
            friends = try modelContext.fetch(descriptor)
            print("✅ MemberSelectionViewModel: Loaded \(friends.count) friends")
        } catch {
            print("⚠️ MemberSelectionViewModel: Failed to load friends - \(error.localizedDescription)")
            friends = []
        }
    }
    
    // MARK: - Actions
    func toggleFriendSelection(_ friend: FriendEntity) {
        guard let id = friend.id else { return }
        if selectedFriendIds.contains(id) {
            selectedFriendIds.remove(id)
        } else {
            selectedFriendIds.insert(id)
        }
    }
    
    func removeFriend(_ friend: FriendEntity) {
        guard let id = friend.id else { return }
        selectedFriendIds.remove(id)
    }
    
    func clearSearch() {
        searchText = ""
    }
    
    func isFriendSelected(_ friend: FriendEntity) -> Bool {
        guard let id = friend.id else { return false }
        return selectedFriendIds.contains(id)
    }
    
    // MARK: - Get Selected Friends
    func getSelectedFriends() -> [FriendEntity] {
        friends.filter { friend in
            guard let id = friend.id else { return false }
            return selectedFriendIds.contains(id)
        }
    }
    
    // MARK: - Create New Friend
    func createNewFriend() {
        let trimmedName = newFriendName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        // Check if friend with same name already exists
        if friends.contains(where: { $0.fullName?.lowercased() == trimmedName.lowercased() }) {
            print("⚠️ Friend with name '\(trimmedName)' already exists")
            newFriendName = ""
            return
        }
        
        // Create new friend
        let newFriend = FriendEntity(
            userId: UUID().uuidString,
            fullName: trimmedName
        )
        newFriend.id = UUID()
        
        // Insert into context
        modelContext.insert(newFriend)
        
        // Save context
        do {
            try modelContext.save()
            
            // Reload friends to include the new one
            loadFriends()
            
            // Automatically select the new friend
            if let id = newFriend.id {
                selectedFriendIds.insert(id)
            }
            
            // Clear the input field
            newFriendName = ""
            
            print("✅ Created new friend: \(trimmedName)")
        } catch {
            print("⚠️ Failed to save new friend: \(error.localizedDescription)")
        }
    }
}
