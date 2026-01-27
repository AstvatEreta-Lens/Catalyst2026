//
//  SettlementModels.swift
//  Talangin
//
//  Created by System on 26/01/26.
//

import Foundation

/// Represents a settlement transaction between two members
struct SettlementTransaction: Identifiable {
    let id = UUID()
    let fromMemberID: UUID
    let fromMemberName: String
    let fromMemberInitials: String
    let toMemberID: UUID
    let toMemberName: String
    let toMemberInitials: String
    let amount: Double
    let relatedExpenses: [ExpenseBreakdown]
    let isPaid: Bool
    
    var status: String {
        isPaid ? "Paid" : "Unpaid"
    }
}

/// Breakdown of expenses contributing to a settlement
struct ExpenseBreakdown: Identifiable {
    let id = UUID()
    let expenseTitle: String
    let expenseDate: Date
    let itemName: String?
    let amount: Double
    let paidBy: String
}

/// Summary of settlements for a specific member
struct MemberSettlementSummary {
    let memberID: UUID
    let memberName: String
    let memberInitials: String
    
    /// Transactions where this member needs to pay others
    let needToPay: [SettlementTransaction]
    
    /// Transactions where this member is waiting for payment from others
    let waitingForPayment: [SettlementTransaction]
    
    var totalNeedToPay: Double {
        needToPay.reduce(0) { $0 + $1.amount }
    }
    
    var totalWaitingForPayment: Double {
        waitingForPayment.reduce(0) { $0 + $1.amount }
    }
}
