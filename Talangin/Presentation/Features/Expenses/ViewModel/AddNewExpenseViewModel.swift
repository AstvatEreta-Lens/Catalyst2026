//
//  AddNewExpenseViewModel.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 17/01/26.
//

import SwiftUI
import SwiftData
import Combine

@MainActor
final class AddNewExpenseViewModel: ObservableObject {
    
    // MARK: - App State
    private var modelContext: ModelContext?
    
    // MARK: - Input State
    @Published var title: String = ""
    @Published var totalPrice: String = ""
    @Published var splitResult: SplitResult = .equally
    
    // MARK: - Selection State
    @Published var selectedFriends: [FriendEntity] = []
    @Published var selectedGroups: [GroupEntity] = []
    @Published var selectedPayers: [Payer] = []
    
    private let preselectedGroup: GroupEntity?
    
    // MARK: - UI Flow State
    @Published var showBeneficiarySheet = false
    @Published var showSplitSchemeSheet = false
    @Published var showPaidBySheet = false
    
    // MARK: - Constants (Static for PoC)
    private static let currentUserID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    private static let currentUserName = "John Doe"
    
    // MARK: - Computed Properties
    
    private var currentUserFriend: FriendEntity {
        FriendEntity(
            id: Self.currentUserID,
            userId: "current_user",
            fullName: "\(Self.currentUserName) (Me)",
            email: nil,
            phoneNumber: nil,
            profilePhotoData: nil
        )
    }
    
    var selectedBeneficiaryAvatars: [(initials: String, type: String)] {
        var result: [(String, String)] = []
        result.append(contentsOf: selectedFriends.map { ($0.avatarInitials, "friend") })
        result.append(contentsOf: selectedGroups.map { ($0.avatarInitials, "group") })
        return result
    }
    
    var allBeneficiaries: [FriendEntity] {
        var uniqueFriends: [FriendEntity] = []
        var seenIDs: Set<UUID> = []
        
        // Add current user first
        uniqueFriends.append(currentUserFriend)
        seenIDs.insert(Self.currentUserID)
        
        // Add individuals
        for friend in selectedFriends {
            if let id = friend.id {
                if !seenIDs.contains(id) {
                    uniqueFriends.append(friend)
                    seenIDs.insert(id)
                }
            }
        }
        
        // Add group members
        for group in selectedGroups {
            for member in group.members ?? [] {
                if let id = member.id {
                    if !seenIDs.contains(id) {
                        uniqueFriends.append(member)
                        seenIDs.insert(id)
                    }
                }
            }
        }
        
        return uniqueFriends
    }
    
    var availablePayers: [Payer] {
        var result: [Payer] = []
        var seenIDs: Set<UUID> = []

        // Add current user first
        result.append(
            Payer(
                id: Self.currentUserID,
                name: Self.currentUserName,
                initials: currentUserFriend.avatarInitials,
                amount: 0,
                isCurrentUser: true
            )
        )
        seenIDs.insert(Self.currentUserID)

        // Add friends
        for friend in selectedFriends {
            guard let id = friend.id, !seenIDs.contains(id) else { continue }
            result.append(
                Payer(
                    id: id,
                    name: friend.fullName ?? "Unknown",
                    initials: friend.avatarInitials,
                    amount: 0,
                    isCurrentUser: false
                )
            )
            seenIDs.insert(id)
        }

        // Add group members
        for group in selectedGroups {
            for member in group.members ?? [] {
                guard let id = member.id, !seenIDs.contains(id) else { continue }
                result.append(
                    Payer(
                        id: id,
                        name: member.fullName ?? "Unknown",
                        initials: member.avatarInitials,
                        amount: 0,
                        isCurrentUser: false
                    )
                )
                seenIDs.insert(id)
            }
        }

        return result
    }
    
    var isFormValid: Bool {
        !title.isEmpty &&
        !totalPrice.isEmpty &&
        !selectedPayers.isEmpty &&
        !allBeneficiaries.isEmpty &&
        splitResult.method != .none
    }
    
    // MARK: - Initialization
    
    init(group: GroupEntity? = nil) {
        self.preselectedGroup = group
        if let group = group {
            self.selectedGroups = [group]
        }
    }
    
    func injectContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    // MARK: - Actions
    
    func saveExpense(onSuccess: @escaping () -> Void) {
        guard isFormValid,
              let amount = Double(totalPrice),
              let context = modelContext else { return }
        
        let repository = ExpenseRepository(modelContext: context)
        
        do {
            print("💾 Saving expense: \(title)")
            try repository.saveExpense(
                title: title,
                totalAmount: amount,
                payers: selectedPayers,
                beneficiaries: allBeneficiaries,
                splitResult: splitResult,
                targetGroup: preselectedGroup
            )
            print("✅ Expense saved successfully!")
            onSuccess()
        } catch {
            print("❌ Error saving expense: \(error)")
        }
    }
    
    func updateBeneficiaries(friends: [FriendEntity], groups: [GroupEntity]) {
        self.selectedFriends = friends
        self.selectedGroups = groups
    }
    
    func updatePayers(_ payers: [Payer]) {
        self.selectedPayers = payers
    }
}
