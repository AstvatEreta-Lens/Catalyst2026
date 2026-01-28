//
//  SettlementView.swift
//  Talangin
//
//  Created by Ali Jazzy Rasyid on 20/01/26.
//

import SwiftUI
import SwiftData

struct SettlementView: View {
    @Environment(\.modelContext) private var modelContext
    
    // Global data queries
    @Query private var allExpenses: [ExpenseEntity]
    @Query private var allSettlements: [SettlementEntity]
    @Query private var allFriends: [FriendEntity]
    
    // Optional filters for group-specific view
    let member: FriendEntity?
    let group: GroupEntity?
    
    // Local state
    @State private var selectedSegment: SettlementSegment = .debt
    @State private var expandedTransactions: Set<UUID> = []
    @State private var selectedTransaction: SettlementTransaction?
    
    private let currentUserID = UUID(uuidString: "00000000-0000-0000-0000-000000000001") ?? UUID()
    
    init(
        member: FriendEntity? = nil,
        group: GroupEntity? = nil
    ) {
        self.member = member
        self.group = group
    }
    
    private var settlementSummary: MemberSettlementSummary {
        // Filter expenses if a group is provided
        let filteredExpenses = group != nil ? allExpenses.filter { $0.group?.id == group?.id } : allExpenses
        
        return SettlementCalculator.calculateSettlementSummary(
            for: currentUserID,
            memberName: "Me",
            memberInitials: "ME",
            expenses: filteredExpenses,
            allMembers: allFriends,
            settlements: allSettlements
        )
    }
    
    private var filteredTransactions: [SettlementTransaction] {
        switch selectedSegment {
        case .debt:
            return settlementSummary.needToPay
        case .receivable:
            return settlementSummary.waitingForPayment
        case .done:
            return settlementSummary.doneTransactions
        }
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea(edges: .bottom)
            
            ScrollView {
                VStack(spacing: 24) {
                    Picker("Segment", selection: $selectedSegment) {
                        ForEach(SettlementSegment.allCases, id: \.self) {
                            Text($0.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.top, 16)
                    
                    if filteredTransactions.isEmpty {
                        emptyStateView
                    } else {
                        VStack(spacing: 12) {
                            ForEach(filteredTransactions) { transaction in
                                SettlementRowView(
                                    isExpanded: Binding(
                                        get: { expandedTransactions.contains(transaction.id) },
                                        set: { isExpanded in
                                            if isExpanded {
                                                expandedTransactions.insert(transaction.id)
                                            } else {
                                                expandedTransactions.remove(transaction.id)
                                            }
                                        }
                                    ),
                                    onTap: {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                            if expandedTransactions.contains(transaction.id) {
                                                expandedTransactions.remove(transaction.id)
                                            } else {
                                                expandedTransactions.insert(transaction.id)
                                            }
                                        }
                                    },
                                    title: transaction.isPaid ? "Settled" : (selectedSegment == .debt ? "Need to Pay" : "Waiting For Payment"),
                                    amount: transaction.amount,
                                    status: transaction.status,
                                    statusColor: transaction.isPaid ? .green : (selectedSegment == .debt ? .red : .orange),
                                    personName: selectedSegment == .debt ? transaction.toMemberName : transaction.fromMemberName,
                                    personInitials: selectedSegment == .debt ? transaction.toMemberInitials : transaction.fromMemberInitials,
                                    expenseBreakdowns: transaction.relatedExpenses
                                )
                                .onTapGesture {
                                    if !transaction.isPaid && selectedSegment == .debt {
                                        selectedTransaction = transaction
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 100)
            }
        }
        .navigationTitle(group?.name ?? "My Settlements")
        .sheet(item: $selectedTransaction) { transaction in
            PayNowView(transaction: transaction)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 48))
                .foregroundColor(.green)
            Text(selectedSegment == .done ? "No settled transactions yet" : "All settled up!")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 60)
    }
}

#Preview {
    SettlementView()
}

enum SettlementSegment: String, CaseIterable {
    case debt = "Debt"
    case receivable = "Receivable"
    case done = "Done"
}
