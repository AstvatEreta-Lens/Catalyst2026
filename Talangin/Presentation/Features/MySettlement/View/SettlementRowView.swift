//
//  SettlementCardView.swift
//  Talangin
//
//  Created by Ali Jazzy Rasyid on 22/01/26.
//

import SwiftUI

struct SettlementRowView: View {

    @Binding var isExpanded: Bool
    var onTap: () -> Void
    
    // Data for SettlementCard
    let title: String
    let amount: Double
    let status: String
    let statusColor: Color
    let personName: String
    let personInitials: String
    let expenseBreakdowns: [ExpenseBreakdown]
    
    init(
        isExpanded: Binding<Bool>,
        onTap: @escaping () -> Void,
        title: String,
        amount: Double,
        status: String,
        statusColor: Color,
        personName: String,
        personInitials: String,
        expenseBreakdowns: [ExpenseBreakdown] = []
    ) {
        self._isExpanded = isExpanded
        self.onTap = onTap
        self.title = title
        self.amount = amount
        self.status = status
        self.statusColor = statusColor
        self.personName = personName
        self.personInitials = personInitials
        self.expenseBreakdowns = expenseBreakdowns
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            SettlementCard(
                title: title,
                amount: amount,
                status: status,
                statusColor: statusColor,
                personName: personName,
                personInitials: personInitials
            )
            .zIndex(1)
            // -- Footer See Details --
            VStack(spacing: 0) {
                Button(action: onTap) {
                    HStack {
                        Text("See Details")
                            .font(.footnote)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    }
                    .padding()
                    .foregroundStyle(.blue)
                }
                
                if isExpanded && !expenseBreakdowns.isEmpty {
                    VStack(spacing: 12) {
                        ForEach(expenseBreakdowns) { breakdown in
                            ExpenseBreakdownCard(breakdown: breakdown)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 12)
                }
            }
            .background(Color.blue.opacity(0.1))
            .clipShape(
                UnevenRoundedRectangle(
                    bottomLeadingRadius: 12,
                    bottomTrailingRadius: 12
                )
            )
            .offset(y: -6)
        }
    }
}

// MARK: - Expense Breakdown Card
struct ExpenseBreakdownCard: View {
    let breakdown: ExpenseBreakdown
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    if let itemName = breakdown.itemName {
                        Text(itemName)
                            .font(.callout)
                            .fontWeight(.medium)
                    }
                    Text(breakdown.expenseTitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(formatRupiah(breakdown.amount))
                    .font(.callout)
                    .fontWeight(.bold)
            }
            
            HStack(spacing: 4) {
                Text("Paid by")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(breakdown.paidBy)
                    .font(.caption2)
                    .fontWeight(.medium)
                Spacer()
                Text(breakdown.expenseDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private func formatRupiah(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        return "Rp " + (formatter.string(from: NSNumber(value: amount)) ?? "0")
    }
}
