//
//  ExpenseDetailViewModel.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 25/01/26.
//

import Foundation
import SwiftData
import SwiftUI
import Combine

@MainActor
final class ExpenseDetailViewModel: ObservableObject {
    @Published var expense: ExpenseEntity
    
    init(expense: ExpenseEntity) {
        self.expense = expense
    }
    
    var title: String {
        expense.title ?? "Untitled Expense"
    }
    
    var totalAmount: Double {
        expense.totalAmount ?? 0
    }
    
    var payers: [PayerCodable] {
        expense.payers
    }
    
    var beneficiaries: [BeneficiaryCodable] {
        expense.beneficiaries
    }
    
    var splitMethod: SplitMethod {
        SplitMethod(rawValue: expense.splitMethodRaw ?? "Equally") ?? .equally
    }
    
    var items: [ExpenseItem] {
        guard splitMethod == .itemized, let data = expense.splitDetailsData else { return [] }
        return (try? JSONDecoder().decode([ExpenseItem].self, from: data)) ?? []
    }
    
    var splitBreakdown: [PayerCodable] {
        let total = totalAmount
        let count = beneficiaries.count
        let share = count > 0 ? total / Double(count) : 0
        
        switch splitMethod {
        case .equally:
            return beneficiaries.map { ben in
                PayerCodable(
                    id: ben.id,
                    displayName: ben.fullName,
                    initials: ben.avatarInitials,
                    isCurrentUser: false, // Not used in display
                    amount: share
                )
            }
        case .unequally:
            if let data = expense.splitDetailsData,
               let amounts = try? JSONDecoder().decode([UUID: Double].self, from: data) {
                return beneficiaries.map { ben in
                    PayerCodable(
                        id: ben.id,
                        displayName: ben.fullName,
                        initials: ben.avatarInitials,
                        isCurrentUser: false,
                        amount: amounts[ben.id] ?? 0
                    )
                }
            }
        case .itemized:
            if let data = expense.splitDetailsData,
               let items = try? JSONDecoder().decode([ExpenseItem].self, from: data) {
                // For itemized, we aggregate per beneficiary
                var aggregated: [UUID: Double] = [:]
                for item in items {
                    if let benID = item.assignedBeneficiaryID {
                        aggregated[benID, default: 0] += item.price
                    }
                }
                return beneficiaries.map { ben in
                    PayerCodable(
                        id: ben.id,
                        displayName: ben.fullName,
                        initials: ben.avatarInitials,
                        isCurrentUser: false,
                        amount: aggregated[ben.id] ?? 0
                    )
                }
            }
        default:
            break
        }
        return []
    }
    
    func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "Rp"
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "Rp 0"
    }
}
