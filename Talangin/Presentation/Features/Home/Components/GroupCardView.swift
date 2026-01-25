//
//  GroupCardView.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 16/01/26.
//

import SwiftUI

struct GroupCardView: View {
    let group: GroupEntity
    let currentUserID: UUID
    
    var body: some View {
        HStack(spacing: 12) {
            // Group Avatar
            GroupIconView(group: group, size: .small)
                .frame(width: 52, height: 52)
                .background(Color(red: 0.95, green: 0.96, blue: 0.92)) // Subtle tinted background for icon
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(group.name ?? "Untitled Group")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(group.memberCount > 0 ? "Waiting for members..." : "No members yet")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            HStack(spacing: 4) {
                Text(formatAmount(totalGroupExpenses))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary.opacity(0.3))
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
    }
    
    private var totalGroupExpenses: Double {
        group.expenses?.compactMap { $0.totalAmount }.reduce(0, +) ?? 0
    }
    
    private func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "Rp"
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "Rp 0"
    }
}


