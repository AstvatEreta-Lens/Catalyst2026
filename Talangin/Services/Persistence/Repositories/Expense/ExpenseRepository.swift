//
//  ExpenseRepository.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 16/01/26.
//

import SwiftData
import Foundation

@MainActor
final class ExpenseRepository {
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Create
    func saveExpense(
        title: String,
        totalAmount: Double,
        payers: [Payer],
        beneficiaries: [FriendEntity],
        splitResult: SplitResult,
        targetGroup: GroupEntity? = nil
    ) throws {
        // Encode payers
        let payersCodable = payers.map { payer in
            PayerCodable(
                id: payer.id,
                displayName: payer.displayName,
                initials: payer.initials,
                isCurrentUser: payer.isCurrentUser,
                amount: payer.amount
            )
        }
        let payersData = try? JSONEncoder().encode(payersCodable)
        
        // Encode beneficiaries
        let beneficiariesCodable = beneficiaries.map { friend in
            BeneficiaryCodable(
                id: friend.id ?? UUID(),
                fullName: friend.fullName ?? "Unknown Participant",
                avatarInitials: friend.avatarInitials
            )
        }
        let beneficiariesData = try? JSONEncoder().encode(beneficiariesCodable)
        
        // Encode split details based on method
        var splitDetailsData: Data? = nil
        var persistenceItems: [ExpenseItemEntity] = []
        
        switch splitResult {
        case .unequally(let amounts):
            splitDetailsData = try? JSONEncoder().encode(amounts)
        case .itemized(let items):
            splitDetailsData = try? JSONEncoder().encode(items)
            persistenceItems = items.map { item in
                ExpenseItemEntity(
                    id: item.id,
                    name: item.name,
                    price: item.price,
                    assignedBeneficiaryID: item.assignedBeneficiaryID
                )
            }
        default:
            break
        }
        
        let groupToLink: GroupEntity
        
        if let targetGroup = targetGroup {
            print("📦 Using provided target group: \(targetGroup.name ?? "Untitled")")
            groupToLink = targetGroup
        } else {
            // Create Untitled Group with all participants
            let groupRepository = GroupRepository(modelContext: modelContext)
            
            print("📦 Creating Untitled Group...")
            print("👥 Beneficiaries to add: \(beneficiaries.count)")
            
            // Combine all unique participants and ensure they're persisted
            var allMembers: [FriendEntity] = []
            var seenIDs: Set<UUID> = []
            
            for beneficiary in beneficiaries {
                if let id = beneficiary.id {
                    if !seenIDs.contains(id) {
                        let descriptor = FetchDescriptor<FriendEntity>(predicate: #Predicate { $0.id == id })
                        
                        if let existing = try? modelContext.fetch(descriptor).first {
                            print("  🔗 Using existing entity: \(existing.fullName ?? "Unknown")")
                            allMembers.append(existing)
                        } else {
                            print("  ➕ Inserting new entity: \(beneficiary.fullName ?? "Unknown")")
                            modelContext.insert(beneficiary)
                            allMembers.append(beneficiary)
                        }
                        seenIDs.insert(id)
                    }
                }
            }
            
            print("💾 Saving \(allMembers.count) members to database...")
            try modelContext.save()
            
            print("🏗️ Creating group with \(allMembers.count) members...")
            groupToLink = try groupRepository.createGroup(
                name: "Untitled Group",
                description: "Auto-created from expense: \(title)",
                members: allMembers
            )
            print("✅ Group created with ID: \(groupToLink.id?.uuidString ?? "nil")")
        }
        
        let expense = ExpenseEntity(
            title: title,
            totalAmount: totalAmount,
            splitMethodRaw: splitResult.method.rawValue,
            payersData: payersData,
            beneficiariesData: beneficiariesData,
            splitDetailsData: splitDetailsData,
            group: groupToLink
        )
        
        if !persistenceItems.isEmpty {
            expense.items = persistenceItems
            print("📑 Linked \(persistenceItems.count) items to expense")
        }
        
        modelContext.insert(expense)
        try modelContext.save()
        
        print("✅ Expense saved and linked to group!")
        
        // Items verification log
        if let savedItems = expense.items {
            print("🔍 Verification: Expense '\(expense.title ?? "")' now has \(savedItems.count) persistent items:")
            for item in savedItems {
                print("   - 📦 Item: \(item.name ?? "nil"), Price: \(item.price ?? 0)")
            }
        }
        
        // Final debug check
        let totalGroups = (try? modelContext.fetch(FetchDescriptor<GroupEntity>()))?.count ?? 0
        let totalItems = (try? modelContext.fetch(FetchDescriptor<ExpenseItemEntity>()))?.count ?? 0
        print("📊 Stats: Total groups: \(totalGroups), Total Persistent Items: \(totalItems)")
    }
    
    // MARK: - Read
    func fetchAllExpenses() throws -> [ExpenseEntity] {
        print("🔍 ExpenseRepository: Fetching all expenses...")
        
        do {
            let descriptor = FetchDescriptor<ExpenseEntity>(
                sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
            )
            let expenses = try modelContext.fetch(descriptor)
            print("✅ ExpenseRepository: Fetched \(expenses.count) expenses")
            
            for (index, expense) in expenses.enumerated() {
                let itemCount = expense.items?.count ?? 0
                print("   [\(index)] '\(expense.title ?? "Untitled")' - Rp \(expense.totalAmount ?? 0) (\(itemCount) items)")
            }
            
            return expenses
        } catch {
            print("❌ ExpenseRepository: Failed to fetch expenses - \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Delete
    func deleteExpense(_ expense: ExpenseEntity) throws {
        let expenseTitle = expense.title ?? "Untitled"
        let expenseId = expense.id?.uuidString ?? "nil"
        print("🗑️ ExpenseRepository: Deleting expense '\(expenseTitle)' (ID: \(expenseId))...")
        
        do {
            modelContext.delete(expense)
            try modelContext.save()
            print("✅ ExpenseRepository: Expense '\(expenseTitle)' deleted successfully")
        } catch {
            print("❌ ExpenseRepository: Failed to delete expense - \(error.localizedDescription)")
            throw error
        }
    }
}
