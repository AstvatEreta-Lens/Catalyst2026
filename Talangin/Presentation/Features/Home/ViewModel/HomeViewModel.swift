//
//  HomeViewModel.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 16/01/26.
//

import SwiftUI
import SwiftData
import Observation

@MainActor
@Observable
final class HomeViewModel {
    
    private let modelContext: ModelContext
    private let groupRepository: GroupRepository
    
    var groups: [GroupEntity] = []
    var isLoading = false
    var errorMessage: String?
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.groupRepository = GroupRepository(modelContext: modelContext)
    }
    
    func fetchGroups() {
        isLoading = true
        errorMessage = nil
        
        do {
            groups = try groupRepository.fetchAllGroups()
        } catch {
            errorMessage = "Failed to load groups: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // Calculate summary for a specific member in a group
    func calculateMemberSummary(for memberID: UUID, in group: GroupEntity) -> (needToPay: Double, waitingForPayment: Double) {
        // TODO: Implement actual calculation based on expenses
        // For now, return placeholder values
        return (needToPay: 45000, waitingForPayment: 45000)
    }
}
