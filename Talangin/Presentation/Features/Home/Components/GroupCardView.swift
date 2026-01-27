//
//  GroupCardView.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 16/01/26.
//

import SwiftUI
import SwiftData

struct GroupCardView: View {
    let group: GroupEntity
    let currentUserID: UUID
    
    var body: some View {
        HStack(spacing: 12) {
            // Group Avatar
            GroupIconView(group: group, size: .small)
                .frame(width: 40, height: 40)
                .background(Color(red: 0.95, green: 0.96, blue: 0.92)) // Subtle tinted background for icon
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(group.name ?? "Untitled Group")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(group.memberCount > 0 ? "Waiting for members..." : "No members yet")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
          
            HStack(spacing: 8) {
                VStack(spacing: 2){
                    Text("Total")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.secondary)
                        
                    Text(formatAmount(totalGroupExpenses))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                }

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

#Preview {
    let container = try! ModelContainer(for: GroupEntity.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    
    // Group 1: With expenses
    let group1 = GroupEntity(
        name: "Trip To Bromo",
        groupDescription: "Patungan biaya bromo",
        iconName: "mountain.2.fill",
        iconBackgroundColorHex: "#E8F5E9"
    )
    container.mainContext.insert(group1)
    
    let expense1 = ExpenseEntity(
        title: "Jeep Rental",
        totalAmount: 1500000,
        splitMethodRaw: "equally",
        group: group1
    )
    container.mainContext.insert(expense1)
    
    // Group 2: Empty group
    let group2 = GroupEntity(
        name: "Dinner Team",
        groupDescription: "Makan malam mingguan",
        iconName: "fork.knife",
        iconBackgroundColorHex: "#FFF3E0"
    )
    container.mainContext.insert(group2)
    
    return List {
        GroupCardView(group: group1, currentUserID: UUID())
        GroupCardView(group: group2, currentUserID: UUID())
    }
    .listStyle(.plain)
    .modelContainer(container)
}
