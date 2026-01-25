//
//  GroupPageViewModel.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 25/01/26.
//

import Foundation
import SwiftData
import SwiftUI
import Combine

@MainActor
final class GroupPageViewModel: ObservableObject {
    @Published var selectedTab = 0
    @Published var showDeleteConfirmation = false
    @Published var isEditingName = false
    @Published var editedName = ""
    @Published var showImagePicker = false
    @Published var selectedImageData: Data? = nil
    @Published var showAddExpenseSheet = false
    
    let group: GroupEntity
    let currentUserID: UUID
    private let modelContext: ModelContext
    
    init(group: GroupEntity, currentUserID: UUID, modelContext: ModelContext) {
        self.group = group
        self.currentUserID = currentUserID
        self.modelContext = modelContext
        self.editedName = group.name ?? ""
    }
    
    func updateGroupName() {
        guard !editedName.isEmpty else { return }
        group.name = editedName
        saveChanges()
    }
    
    func updateGroupImage(data: Data) {
        group.groupPhotoData = data
        saveChanges()
    }
    
    private func saveChanges() {
        let repository = GroupRepository(modelContext: modelContext)
        do {
            try repository.updateGroup(group)
            objectWillChange.send() // Force UI update
        } catch {
            print("❌ GroupPageViewModel: Failed to update group - \(error.localizedDescription)")
        }
    }
    
    func deleteGroup(onSuccess: @escaping () -> Void) {
        let repository = GroupRepository(modelContext: modelContext)
        do {
            try repository.deleteGroup(group)
            print("✅ GroupPageViewModel: Group deleted successfully")
            onSuccess()
        } catch {
            print("❌ GroupPageViewModel: Failed to delete group - \(error.localizedDescription)")
        }
    }
    
    var members: [FriendEntity] {
        group.members ?? []
    }
    
    var expenses: [ExpenseEntity] {
        let groupId = group.id
        let descriptor = FetchDescriptor<ExpenseEntity>(
            predicate: #Predicate { $0.group?.id == groupId },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    var groupedExpenses: [(Date, [ExpenseEntity])] {
        let grouped = Dictionary(grouping: expenses) { expense in
            Calendar.current.startOfDay(for: expense.createdAt ?? Date())
        }
        return grouped.sorted { $0.key > $1.key }
    }
    
    var groupName: String {
        group.name ?? "Untitled Group"
    }
    
    var memberCount: Int {
        group.memberCount
    }
    
    var creationDateString: String {
        group.createdAt?.formatted(date: .abbreviated, time: .omitted) ?? "20 Jan 2026"
    }
    
    func memberSummary(for memberID: UUID?) -> (youNeedToPay: Double, waitingForPayment: Double) {
        guard let memberID = memberID else { return (0, 0) }
        var totalOwes = 0.0
        var totalOwedToMe = 0.0
        
        for expense in expenses {
            let payers = expense.payers
            let beneficiaries = expense.beneficiaries
            let total = expense.totalAmount ?? 0
            let method = SplitMethod(rawValue: expense.splitMethodRaw ?? "Equally") ?? .equally
            
            var myShare = 0.0
            if beneficiaries.contains(where: { $0.id == memberID }) {
                switch method {
                case .equally:
                    let count = beneficiaries.count
                    myShare = count > 0 ? total / Double(count) : 0
                case .unequally:
                    if let data = expense.splitDetailsData,
                       let amounts = try? JSONDecoder().decode([UUID: Double].self, from: data) {
                        myShare = amounts[memberID] ?? 0
                    }
                case .itemized:
                    if let data = expense.splitDetailsData,
                       let items = try? JSONDecoder().decode([ExpenseItem].self, from: data) {
                        myShare = items.filter { $0.assignedBeneficiaryID == memberID }.map { $0.price }.reduce(0, +)
                    }
                default:
                    break
                }
            }
            
            let myPayment = payers.first(where: { $0.id == memberID })?.amount ?? 0
            let balance = myPayment - myShare
            
            if balance < 0 {
                totalOwes += abs(balance)
            } else if balance > 0 {
                totalOwedToMe += balance
            }
        }
        
        return (totalOwes, totalOwedToMe)
    }
}
