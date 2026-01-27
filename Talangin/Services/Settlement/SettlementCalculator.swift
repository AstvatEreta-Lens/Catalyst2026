//
//  SettlementCalculator.swift
//  Talangin
//
//  Created by System on 26/01/26.
//

import Foundation

/// Service to calculate settlements between group members
@MainActor
final class SettlementCalculator {
    
    /// Calculate settlement summary for a specific member in a group
    static func calculateSettlementSummary(
        for memberID: UUID,
        memberName: String,
        memberInitials: String,
        expenses: [ExpenseEntity],
        allMembers: [FriendEntity]
    ) -> MemberSettlementSummary {
        
        // Calculate balances between this member and all other members
        var balances: [UUID: Double] = [:] // positive = they owe me, negative = I owe them
        var expenseDetails: [UUID: [ExpenseBreakdown]] = [:]
        
        for expense in expenses {
            let payers = expense.payers
            let beneficiaries = expense.beneficiaries
            let total = expense.totalAmount ?? 0
            let method = SplitMethod(rawValue: expense.splitMethodRaw ?? "Equally") ?? .equally
            let expenseTitle = expense.title ?? "Untitled"
            let expenseDate = expense.createdAt ?? Date()
            
            // Calculate this member's share
            var myShare = 0.0
            var myItems: [ExpenseItem] = []
            
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
                        myItems = items.filter { $0.assignedBeneficiaryID == memberID }
                        myShare = myItems.map { $0.price }.reduce(0, +)
                    }
                default:
                    break
                }
            }
            
            // Calculate how much this member paid
            let myPayment = payers.first(where: { $0.id == memberID })?.amount ?? 0
            
            // If I paid more than my share, others owe me
            // If I paid less than my share, I owe others
            let myBalance = myPayment - myShare
            
            // Distribute the balance among other payers/beneficiaries
            if myBalance != 0 {
                // Find who actually paid for this expense
                for payer in payers where payer.id != memberID {
                    let payerID = payer.id
                    let payerAmount = payer.amount
                    
                    // Calculate what portion of my balance relates to this payer
                    let totalPaid = payers.reduce(0) { $0 + $1.amount }
                    let payerProportion = totalPaid > 0 ? payerAmount / totalPaid : 0
                    
                    if myBalance < 0 {
                        // I owe money - distribute my debt proportionally to payers
                        let amountOwed = abs(myBalance) * payerProportion
                        balances[payerID, default: 0] -= amountOwed
                        
                        // Track expense details
                        if !myItems.isEmpty {
                            for item in myItems {
                                let breakdown = ExpenseBreakdown(
                                    expenseTitle: expenseTitle,
                                    expenseDate: expenseDate,
                                    itemName: item.name,
                                    amount: item.price * payerProportion,
                                    paidBy: payer.displayName
                                )
                                expenseDetails[payerID, default: []].append(breakdown)
                            }
                        } else {
                            let breakdown = ExpenseBreakdown(
                                expenseTitle: expenseTitle,
                                expenseDate: expenseDate,
                                itemName: nil,
                                amount: amountOwed,
                                paidBy: payer.displayName
                            )
                            expenseDetails[payerID, default: []].append(breakdown)
                        }
                    } else {
                        // I'm owed money - track who owes me
                        // This is handled from the other person's perspective
                    }
                }
                
                // Also check beneficiaries who didn't pay
                if myBalance > 0 {
                    for beneficiary in beneficiaries where beneficiary.id != memberID {
                        let beneficiaryID = beneficiary.id
                        let beneficiaryPaid = payers.first(where: { $0.id == beneficiaryID })?.amount ?? 0
                        
                        // Calculate their share
                        var theirShare = 0.0
                        switch method {
                        case .equally:
                            let count = beneficiaries.count
                            theirShare = count > 0 ? total / Double(count) : 0
                        case .unequally:
                            if let data = expense.splitDetailsData,
                               let amounts = try? JSONDecoder().decode([UUID: Double].self, from: data) {
                                theirShare = amounts[beneficiaryID] ?? 0
                            }
                        case .itemized:
                            if let data = expense.splitDetailsData,
                               let items = try? JSONDecoder().decode([ExpenseItem].self, from: data) {
                                theirShare = items.filter { $0.assignedBeneficiaryID == beneficiaryID }.map { $0.price }.reduce(0, +)
                            }
                        default:
                            break
                        }
                        
                        let theirBalance = beneficiaryPaid - theirShare
                        if theirBalance < 0 {
                            // They owe money, and I paid, so they owe me
                            let totalPaid = payers.reduce(0) { $0 + $1.amount }
                            let myProportion = totalPaid > 0 ? myPayment / totalPaid : 0
                            let amountOwedToMe = abs(theirBalance) * myProportion
                            
                            balances[beneficiaryID, default: 0] += amountOwedToMe
                            
                            let breakdown = ExpenseBreakdown(
                                expenseTitle: expenseTitle,
                                expenseDate: expenseDate,
                                itemName: nil,
                                amount: amountOwedToMe,
                                paidBy: memberName
                            )
                            expenseDetails[beneficiaryID, default: []].append(breakdown)
                        }
                    }
                }
            }
        }
        
        // Convert balances to transactions
        var needToPay: [SettlementTransaction] = []
        var waitingForPayment: [SettlementTransaction] = []
        
        for (otherMemberID, balance) in balances {
            guard let otherMember = allMembers.first(where: { $0.id == otherMemberID }) else { continue }
            
            let otherName = otherMember.fullName ?? "Unknown"
            let otherInitials = otherMember.avatarInitials
            
            if balance < 0 {
                // I owe them
                let transaction = SettlementTransaction(
                    fromMemberID: memberID,
                    fromMemberName: memberName,
                    fromMemberInitials: memberInitials,
                    toMemberID: otherMemberID,
                    toMemberName: otherName,
                    toMemberInitials: otherInitials,
                    amount: abs(balance),
                    relatedExpenses: expenseDetails[otherMemberID] ?? [],
                    isPaid: false
                )
                needToPay.append(transaction)
            } else if balance > 0 {
                // They owe me
                let transaction = SettlementTransaction(
                    fromMemberID: otherMemberID,
                    fromMemberName: otherName,
                    fromMemberInitials: otherInitials,
                    toMemberID: memberID,
                    toMemberName: memberName,
                    toMemberInitials: memberInitials,
                    amount: balance,
                    relatedExpenses: expenseDetails[otherMemberID] ?? [],
                    isPaid: false
                )
                waitingForPayment.append(transaction)
            }
        }
        
        return MemberSettlementSummary(
            memberID: memberID,
            memberName: memberName,
            memberInitials: memberInitials,
            needToPay: needToPay.sorted { $0.amount > $1.amount },
            waitingForPayment: waitingForPayment.sorted { $0.amount > $1.amount }
        )
    }
}
