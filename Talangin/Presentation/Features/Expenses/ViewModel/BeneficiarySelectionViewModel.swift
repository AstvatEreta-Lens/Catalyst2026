//
//  BeneficiarySelectionViewModel.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 12/01/26.
//

import SwiftUI
import Observation

@Observable
final class BeneficiarySelectionViewModel {
    
    struct SelectedBeneficiary: Identifiable, Equatable {
        let id: UUID
        let name: String
        let initials: String
        let isFriend: Bool
    }
    
    
    // MARK: - State
    var friends: [FriendEntity] = []
    var groups: [GroupEntity] = []
    var selectedFriendIds: Set<UUID> = []
    var selectedGroupIds: Set<UUID> = []
    var searchText: String = ""
    
    // MARK: - Computed Properties
    var filteredFriends: [FriendEntity] {
        if searchText.isEmpty {
            return friends
        }
        return friends.filter { friend in
            (friend.fullName ?? "").localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var filteredGroups: [GroupEntity] {
        if searchText.isEmpty {
            return groups
        }
        return groups.filter { group in
            (group.name ?? "").localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var allSelectedBeneficiaries: [SelectedBeneficiary] {
        var result: [SelectedBeneficiary] = []
        
        // Add selected friends
        for friendId in selectedFriendIds {
            if let friend = friends.first(where: { $0.id == friendId }) {
                result.append(SelectedBeneficiary(
                    id: friendId,
                    name: friend.fullName ?? "Unknown",
                    initials: friend.avatarInitials,
                    isFriend: true
                ))
            }
        }
        
        // Add selected groups
        for groupId in selectedGroupIds {
            if let group = groups.first(where: { $0.id == groupId }) {
                result.append(SelectedBeneficiary(
                    id: groupId,
                    name: group.name ?? "Unknown",
                    initials: group.avatarInitials,
                    isFriend: false
                ))
            }
        }
        
        return result
    }
    
    // MARK: - Initialization
    init() {
        loadMockData()
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
    
    func toggleGroupSelection(_ group: GroupEntity) {
        guard let id = group.id else { return }
        if selectedGroupIds.contains(id) {
            selectedGroupIds.remove(id)
        } else {
            selectedGroupIds.insert(id)
        }
    }
    
    func clearSearch() {
        searchText = ""
    }
    
    func isFriendSelected(_ friend: FriendEntity) -> Bool {
        guard let id = friend.id else { return false }
        return selectedFriendIds.contains(id)
    }
    
    func isGroupSelected(_ group: GroupEntity) -> Bool {
        guard let id = group.id else { return false }
        return selectedGroupIds.contains(id)
    }
    
    // MARK: - Mock Data
    private func loadMockData() {
        // Create mock friends
        let friend1 = FriendEntity(userId: "user1", fullName: "Budi")
        let friend2 = FriendEntity(userId: "user2", fullName: "Santoso")
        let friend3 = FriendEntity(userId: "user3", fullName: "Ria")
        let friend4 = FriendEntity(userId: "user4", fullName: "Ahmad Luthfi")
        let friend5 = FriendEntity(userId: "user5", fullName: "Rudi Qomarudin")
        
        friends = [friend1, friend2, friend3, friend4, friend5]
        
//        // Create mock groups
//        let group1 = GroupEntity(name: "Kemping", members: [friend1, friend2, friend3])
//        let group2 = GroupEntity(name: "Kantor", members: [friend4, friend5])
//        
//        groups = [group1, group2]
    }
}
