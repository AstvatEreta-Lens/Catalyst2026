//
//  MemberSummaryCardView.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 25/01/26.
//


import SwiftUI
import SwiftData

struct MemberSummaryCardView: View {

    // MARK: - Properties
    let member: FriendEntity
    let currentUserID: UUID
    let youNeedToPay: Double
    let waitingForPayment: Double
    let group: GroupEntity?
    let expenses: [ExpenseEntity]
    let allMembers: [FriendEntity]

    // MARK: - Body
    var body: some View {
        NavigationLink {
            SettlementView(
                member: member,
                group: group,
                expenses: expenses,
                allMembers: allMembers
            )
        } label: {
            VStack(spacing: 10) {
                headerSection
                amountSection
            }
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Subviews
private extension MemberSummaryCardView {

    // Header
    var headerSection: some View {
        HStack(spacing: 12) {
            avatarView

            Text(displayName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.primary)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondary.opacity(0.4))
        }
    }

    // Avatar
    var avatarView: some View {
        Circle()
            .fill(Color(uiColor: .systemGray5))
            .frame(width: 36, height: 36)
            .overlay(
                Text(member.avatarInitials)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)
            )
    }

    // Amount Section
    var amountSection: some View {
        HStack {
            amountBlock(
                title: "You Need To Pay",
                value: youNeedToPay,
                icon: "arrow.up.right",
                color: .red
            )

            Spacer()

            amountBlock(
                title: "Waiting For Payment",
                value: waitingForPayment,
                icon: "arrow.down.left",
                color: .green
            )
        }
    }

    // Amount Block
    func amountBlock(
        title: String,
        value: Double,
        icon: String,
        color: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2)
                    .foregroundColor(color)

                Text(formatCurrency(value))
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.primary)
            }
        }
    }

    // Display Name
    var displayName: String {
        if member.id == currentUserID {
            return "\(member.fullName ?? "Unknown") (Me)"
        }
        return member.fullName ?? "Unknown"
    }
}

// MARK: - Formatter
private extension MemberSummaryCardView {

    static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "Rp"
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    func formatCurrency(_ amount: Double) -> String {
        Self.currencyFormatter.string(from: NSNumber(value: amount)) ?? "Rp 0"
    }
}
#Preview {
    let container = try! ModelContainer(for: 
        FriendEntity.self, 
        GroupEntity.self, 
        ExpenseEntity.self, 
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    let mockFriend = FriendEntity(
        userId: "user-123",
        fullName: "Ahmad Al Wabil"
    )
    container.mainContext.insert(mockFriend)
    
    let mockGroup = GroupEntity(
        name: "Trip To Bromo",
        groupDescription: "Patungan biaya bromo",
        iconName: "mountain.2.fill",
        iconBackgroundColorHex: "#E8F5E9"
    )
    container.mainContext.insert(mockGroup)
    
    return NavigationStack {
        MemberSummaryCardView(
            member: mockFriend,
            currentUserID: UUID(),
            youNeedToPay: 500000,
            waitingForPayment: 250000,
            group: mockGroup,
            expenses: [],
            allMembers: [mockFriend]
        )
        .padding()
        .background(Color(uiColor: .systemGroupedBackground))
    }
    .modelContainer(container)
}
