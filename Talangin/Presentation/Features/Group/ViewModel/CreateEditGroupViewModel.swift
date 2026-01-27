//
//  CreateEditGroupViewModel.swift
//  Talangin
//
//  Created by Rifqi Rahman on 27/01/26.
//
//  ViewModel for Create and Edit Group functionality.
//  Manages state for group name, photo, members, and payment due date.
//

import Foundation
import SwiftData
import SwiftUI
import Combine

@MainActor
final class CreateEditGroupViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var groupName: String = ""
    @Published var groupPhotoData: Data?
    @Published var selectedMembers: [FriendEntity] = []
    @Published var paymentDueDate: Date?
    @Published var showMemberSelection = false
    @Published var showProfilePictureSheet = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    // MARK: - Available Friends
    @Published var availableFriends: [FriendEntity] = []
    
    // MARK: - Search
    @Published var searchText: String = ""
    
    // MARK: - Dependencies
    let modelContext: ModelContext
    private lazy var groupRepository: GroupRepository = {
        GroupRepository(modelContext: modelContext)
    }()
    private let currentUserID: UUID
    
    // MARK: - Mode
    let isEditMode: Bool
    private let existingGroup: GroupEntity?
    
    // MARK: - Computed Properties
    var filteredFriends: [FriendEntity] {
        if searchText.isEmpty {
            return availableFriends
        }
        return availableFriends.filter { friend in
            (friend.fullName ?? "").localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var canSave: Bool {
        !groupName.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var paymentDueDateText: String {
        if let date = paymentDueDate {
            return date.formatted("dd MMMM yyyy")
        }
        return "Due date for payment"
    }
    
    var membersText: String {
        if selectedMembers.isEmpty {
            return "Select People"
        }
        return "\(selectedMembers.count) member\(selectedMembers.count > 1 ? "s" : "")"
    }
    
    // MARK: - Initialization
    init(
        modelContext: ModelContext,
        currentUserID: UUID,
        existingGroup: GroupEntity? = nil
    ) {
        self.modelContext = modelContext
        // GroupRepository is lazy - will be initialized when first accessed
        self.currentUserID = currentUserID
        self.existingGroup = existingGroup
        self.isEditMode = existingGroup != nil
        
        if let group = existingGroup {
            // Edit mode: populate with existing data
            // NOTE: Only access simple properties in init, not relationships
            // Relationships will be loaded in loadGroupData() called from onAppear
            self.groupName = group.name ?? ""
            self.groupPhotoData = group.groupPhotoData
            self.paymentDueDate = group.paymentDueDate
            // Don't access group.members here - it's a relationship that needs MainActor context
            // Will be loaded in loadGroupData()
        }
        
        // Don't load friends in init - wait for onAppear
        // This prevents crashes in Preview where ModelContext might not be fully ready
        // Friends will be loaded in reloadFriends() called from view's onAppear
    }
    
    // MARK: - Data Loading
    /// Safely loads friends with error handling
    private func loadFriendsSafely() {
        do {
            let descriptor = FetchDescriptor<FriendEntity>(
                sortBy: [SortDescriptor(\.fullName)]
            )
            availableFriends = try modelContext.fetch(descriptor)
            print("✅ CreateEditGroupViewModel: Loaded \(availableFriends.count) friends")
        } catch {
            print("⚠️ CreateEditGroupViewModel: Failed to load friends during init - \(error.localizedDescription)")
            // Set empty array to prevent crashes, error will be handled in onAppear
            availableFriends = []
            errorMessage = "Failed to load friends: \(error.localizedDescription)"
            // Don't show error alert during init - let view handle it in onAppear
        }
    }
    
    /// Public method to reload friends (called from view's onAppear)
    func reloadFriends() {
        loadFriendsSafely()
        if let error = errorMessage, !error.isEmpty {
            showError = true
        }
    }
    
    /// Loads group data including relationships (must be called from MainActor context)
    /// This should be called from view's onAppear to safely access SwiftData relationships
    func loadGroupData() {
        guard let group = existingGroup else { return }
        
        // Safely access relationship on MainActor
        // This ensures we're on the correct thread for SwiftData operations
        selectedMembers = group.members ?? []
        
        print("✅ CreateEditGroupViewModel: Loaded \(selectedMembers.count) members from group")
    }
    
    // MARK: - Member Management
    func toggleMemberSelection(_ friend: FriendEntity) {
        guard let friendId = friend.id else { return }
        
        if let index = selectedMembers.firstIndex(where: { $0.id == friendId }) {
            selectedMembers.remove(at: index)
        } else {
            selectedMembers.append(friend)
        }
    }
    
    func isMemberSelected(_ friend: FriendEntity) -> Bool {
        guard let friendId = friend.id else { return false }
        return selectedMembers.contains(where: { $0.id == friendId })
    }
    
    func removeMember(_ friend: FriendEntity) {
        guard let friendId = friend.id else { return }
        selectedMembers.removeAll(where: { $0.id == friendId })
    }
    
    // MARK: - Photo Management
    func updateGroupPhoto(_ data: Data) {
        groupPhotoData = data
    }
    
    // MARK: - Save/Create
    func saveGroup(onSuccess: @escaping () -> Void) {
        guard canSave else {
            errorMessage = "Please enter a group name"
            showError = true
            return
        }
        
        isLoading = true
        
        do {
            if isEditMode, let group = existingGroup {
                // Update existing group
                group.name = groupName.trimmingCharacters(in: .whitespaces)
                group.groupPhotoData = groupPhotoData
                group.members = selectedMembers
                group.paymentDueDate = paymentDueDate
                group.updatedAt = .now
                
                try groupRepository.updateGroup(group)
                print("✅ CreateEditGroupViewModel: Group updated successfully")
            } else {
                // Create new group
                let newGroup = try groupRepository.createGroup(
                    name: groupName.trimmingCharacters(in: .whitespaces),
                    description: nil,
                    members: selectedMembers
                )
                newGroup.groupPhotoData = groupPhotoData
                newGroup.paymentDueDate = paymentDueDate
                try groupRepository.updateGroup(newGroup)
                print("✅ CreateEditGroupViewModel: Group created successfully")
            }
            
            isLoading = false
            onSuccess()
        } catch {
            isLoading = false
            errorMessage = "Failed to save group: \(error.localizedDescription)"
            showError = true
            print("❌ CreateEditGroupViewModel: Failed to save group - \(error.localizedDescription)")
        }
    }
    
    // MARK: - Calculate Default Payment Due Date
    /// Calculates default payment due date (7 days after last expense)
    func calculateDefaultPaymentDueDate() -> Date {
        guard let group = existingGroup,
              let lastExpense = group.expenses?.max(by: { ($0.createdAt ?? Date.distantPast) < ($1.createdAt ?? Date.distantPast) }),
              let expenseDate = lastExpense.createdAt else {
            // Default to 7 days from now if no expenses
            return Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        }
        
        return Calendar.current.date(byAdding: .day, value: 7, to: expenseDate) ?? Date()
    }
}
