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
                    VStack(alignment: .leading, spacing: 12) {
                        // Group by date if needed, but for now we follow the image's single date header per group if possible
                        // The image shows one date for multiple cards. Let's show the first breakdown's date as header.
                        if let firstDate = expenseBreakdowns.first?.expenseDate {
                            Text(firstDate.formatted(date: .abbreviated, time: .omitted))
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .padding(.leading, 4)
                        }
                        
                        ForEach(expenseBreakdowns) { breakdown in
                            ExpenseBreakdownCard(breakdown: breakdown)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }
            .background(Color.blue.opacity(0.08))
            .clipShape(
                UnevenRoundedRectangle(
                    bottomLeadingRadius: 20,
                    bottomTrailingRadius: 20
                )
            )
            .offset(y: -10)
        }
    }
}

// MARK: - Expense Breakdown Card
struct ExpenseBreakdownCard: View {
    let breakdown: ExpenseBreakdown
    
    var body: some View {
        HStack(spacing: 0) {
            // Left Side: Info
            VStack(alignment: .leading, spacing: 4) {
                Text(breakdown.expenseTitle)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                Text(formatRupiah(breakdown.amount))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            // Right Side: Payer Info
            HStack(spacing: 8) {
                // Initial Circle
                Circle()
                    .fill(Color(uiColor: .systemGray6))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(breakdown.paidByInitials)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.blue)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Paid by")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    
                    Text(breakdown.paidBy)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.secondary.opacity(0.5))
            }
            .padding(.leading, 8)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
    
    private func formatRupiah(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        return "Rp " + (formatter.string(from: NSNumber(value: amount)) ?? "0")
    }
}
