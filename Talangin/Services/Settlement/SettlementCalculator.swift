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
    
    /// Calculate settlement summary for a specific member across expenses and taking settlements into account
    static func calculateSettlementSummary(
        for memberID: UUID,
        memberName: String,
        memberInitials: String,
        expenses: [ExpenseEntity],
        allMembers: [FriendEntity],
        settlements: [SettlementEntity] = []
    ) -> MemberSettlementSummary {
        
        // 1. Calculate raw balances from expenses (positive = they owe me, negative = I owe them)
        var balances: [UUID: Double] = [:] 
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
            let myBalance = myPayment - myShare
            
            if myBalance != 0 {
                // Distribute the balance among other payers/beneficiaries
                if myBalance < 0 {
                    // I owe money - distribute my debt proportionally to payers
                    let totalPaidByOthers = payers.filter({ $0.id != memberID }).reduce(0) { $0 + $1.amount }
                    for payer in payers where payer.id != memberID {
                        let amountOwed = abs(myBalance) * (totalPaidByOthers > 0 ? payer.amount / totalPaidByOthers : 0)
                        balances[payer.id, default: 0] -= amountOwed
                        
                        let breakdown = ExpenseBreakdown(
                            expenseTitle: expenseTitle,
                            expenseDate: expenseDate,
                            itemName: nil,
                            amount: amountOwed,
                            paidBy: payer.displayName,
                            paidByInitials: payer.initials
                        )
                        expenseDetails[payer.id, default: []].append(breakdown)
                    }
                } else {
                    // I'm owed money - check beneficiaries who didn't pay
                    _ = beneficiaries.filter({ b in !payers.contains(where: { $0.id == b.id && $0.amount >= total }) })
                    // For simplicity, we use the logic from previous version which works for most cases
                    for beneficiary in beneficiaries where beneficiary.id != memberID {
                        let beneficiaryID = beneficiary.id
                        let beneficiaryPaid = payers.first(where: { $0.id == beneficiaryID })?.amount ?? 0
                        
                        var theirShare = 0.0
                        switch method {
                        case .equally: theirShare = beneficiaries.count > 0 ? total / Double(beneficiaries.count) : 0
                        case .unequally:
                            if let data = expense.splitDetailsData, let amounts = try? JSONDecoder().decode([UUID: Double].self, from: data) {
                                theirShare = amounts[beneficiaryID] ?? 0
                            }
                        case .itemized:
                            if let data = expense.splitDetailsData, let items = try? JSONDecoder().decode([ExpenseItem].self, from: data) {
                                theirShare = items.filter { $0.assignedBeneficiaryID == beneficiaryID }.map { $0.price }.reduce(0, +)
                            }
                        default: break
                        }
                        
                        let theirBalance = beneficiaryPaid - theirShare
                        if theirBalance < 0 {
                            let totalPaid = payers.reduce(0) { $0 + $1.amount }
                            let myProportion = totalPaid > 0 ? myPayment / totalPaid : 0
                            let amountOwedToMe = abs(theirBalance) * myProportion
                            
                            if amountOwedToMe > 0 {
                                balances[beneficiaryID, default: 0] += amountOwedToMe
                                let breakdown = ExpenseBreakdown(
                                    expenseTitle: expenseTitle,
                                    expenseDate: expenseDate,
                                    itemName: nil,
                                    amount: amountOwedToMe,
                                    paidBy: memberName,
                                    paidByInitials: memberInitials
                                )
                                expenseDetails[beneficiaryID, default: []].append(breakdown)
                            }
                        }
                    }
                }
            }
        }
        
        // 2. Adjust balances with recorded settlements
        for settlement in settlements {
            if settlement.fromMemberID == memberID {
                // I paid someone - reduce my debt
                balances[settlement.toMemberID, default: 0] += settlement.amount
            } else if settlement.toMemberID == memberID {
                // Someone paid me - reduce what they owe me
                balances[settlement.fromMemberID, default: 0] -= settlement.amount
            }
        }
        
        // 3. Convert to transactions
        var needToPay: [SettlementTransaction] = []
        var waitingForPayment: [SettlementTransaction] = []
        var doneTransactions: [SettlementTransaction] = []
        
        // Group settlements by member to show completed ones
        for settlement in settlements {
            if settlement.fromMemberID == memberID || settlement.toMemberID == memberID {
                let otherID = settlement.fromMemberID == memberID ? settlement.toMemberID : settlement.fromMemberID
                guard let otherMember = allMembers.first(where: { $0.id == otherID }) else { continue }
                
                let trans = SettlementTransaction(
                    fromMemberID: settlement.fromMemberID,
                    fromMemberName: settlement.fromMemberID == memberID ? memberName : (otherMember.fullName ?? "Unknown"),
                    fromMemberInitials: settlement.fromMemberID == memberID ? memberInitials : otherMember.avatarInitials,
                    toMemberID: settlement.toMemberID,
                    toMemberName: settlement.toMemberID == memberID ? memberName : (otherMember.fullName ?? "Unknown"),
                    toMemberInitials: settlement.toMemberID == memberID ? memberInitials : otherMember.avatarInitials,
                    amount: settlement.amount,
                    relatedExpenses: [], // We don't track itemized breakdown for done ones yet
                    isPaid: true
                )
                doneTransactions.append(trans)
            }
        }
        
        for (otherMemberID, balance) in balances {
            guard let otherMember = allMembers.first(where: { $0.id == otherMemberID }) else { continue }
            let absBalance = abs(balance)
            if absBalance < 0.01 { continue } // Ignore tiny balances
            
            let otherName = otherMember.fullName ?? "Unknown"
            let otherInitials = otherMember.avatarInitials
            
            if balance < 0 {
                needToPay.append(SettlementTransaction(
                    fromMemberID: memberID, fromMemberName: memberName, fromMemberInitials: memberInitials,
                    toMemberID: otherMemberID, toMemberName: otherName, toMemberInitials: otherInitials,
                    amount: absBalance, relatedExpenses: expenseDetails[otherMemberID] ?? [], isPaid: false
                ))
            } else {
                waitingForPayment.append(SettlementTransaction(
                    fromMemberID: otherMemberID, fromMemberName: otherName, fromMemberInitials: otherInitials,
                    toMemberID: memberID, toMemberName: memberName, toMemberInitials: memberInitials,
                    amount: absBalance, relatedExpenses: expenseDetails[otherMemberID] ?? [], isPaid: false
                ))
            }
        }
        
        return MemberSettlementSummary(
            memberID: memberID,
            memberName: memberName,
            memberInitials: memberInitials,
            needToPay: needToPay.sorted { $0.amount > $1.amount },
            waitingForPayment: waitingForPayment.sorted { $0.amount > $1.amount },
            doneTransactions: doneTransactions.sorted { $1.id.uuidString > $0.id.uuidString } // Sorted by recency (approx)
        )
    }
}
