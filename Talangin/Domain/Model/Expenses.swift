
//
//  Expenses.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 13/01/26.
//

import Foundation

// MARK: - Split Result Model
enum SplitResult: Equatable {
    case none
    case equally
    case unequally(amounts: [UUID: Double])
    case itemized(items: [ExpenseItem])
    
    // Helper to get printable name for the current state (mirroring SplitMethod)
    var method: SplitMethod {
        switch self {
        case .none : return .none
        case .equally: return .equally
        case .unequally: return .unequally
        case .itemized: return .itemized
        }
    }
}

// MARK: - Expense Item Model
struct ExpenseItem: Identifiable, Equatable, Encodable{
    let id: UUID
    var name: String
    var price: Double
    var assignedBeneficiaryID: UUID?
    
    init(id: UUID = UUID(), name: String, price: Double, assignedBeneficiaryID: UUID? = nil) {
        self.id = id
        self.name = name
        self.price = price
        self.assignedBeneficiaryID = assignedBeneficiaryID
    }
}

// MARK: - Split Method Enum
enum SplitMethod: String, CaseIterable, Identifiable {
    case none = "Choose Split Method"
    case equally = "Equally"
    case unequally = "Unequally"
    case itemized = "Itemized"
    
    var id: String {
        self.rawValue
    }
}
