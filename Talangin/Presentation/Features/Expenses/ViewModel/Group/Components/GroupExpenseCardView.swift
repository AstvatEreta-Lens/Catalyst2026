//
//  GroupExpenseCardView.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 25/01/26.
//

import SwiftUI

struct GroupExpenseCardView: View {
    let expense: ExpenseEntity
    
    private var payers: [PayerCodable] {
        expense.payers
    }
    
    private var primaryPayerName: String {
        payers.first?.displayName ?? "Unknown"
    }
    
    private var payerInitials: String {
        payers.count > 1 ? "\(payers.count)+" : (payers.first?.initials ?? "??")
    }
    
    private var payerSubtitle: String {
        if payers.count > 1 {
            let names = payers.prefix(2).map { $0.displayName }
            return names.joined(separator: ", ") + (payers.count > 2 ? "..." : "")
        } else {
            return payers.first?.displayName ?? "Unknown"
        }
    }
    
    var body: some View {
        NavigationLink {
            ExpenseDetailView(expense: expense)
        } label: {
            HStack(spacing: 16) {
                // Left Side: Title and Amount
                VStack(alignment: .leading, spacing: 4) {
                    Text(expense.title ?? "Untitled")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    Text(formatAmount(expense.totalAmount ?? 0))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                // Right Side: Paid By Info
                HStack(spacing: 12) {
                    // Payer Avatar/Icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(uiColor: .secondarySystemBackground))
                            .frame(width: 48, height: 48)
                        
                        Text(payerInitials)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(red: 0.17, green: 0.28, blue: 0.7))
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Paid by")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        
                        Text(payerSubtitle)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                    }
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary.opacity(0.5))
                }
            }
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(.plain)
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
