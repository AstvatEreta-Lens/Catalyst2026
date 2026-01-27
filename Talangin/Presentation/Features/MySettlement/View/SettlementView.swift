//
//  PayNowView.swift
//  Talangin
//
//  Created by Ali Jazzy Rasyid on 20/01/26.
//

import SwiftUI

struct SettlementView: View {
    let member: FriendEntity?
    let group: GroupEntity?
    let expenses: [ExpenseEntity]
    let allMembers: [FriendEntity]
    
    @State private var selectedSegment: SettlementSegment = .active
    @State private var expandedTransactions: Set<UUID> = []
    @State private var selectedFilter = "All"
    @State private var paySheetIsPresented: Bool = false
    @State private var settlementSummary: MemberSettlementSummary?
    
    init(
        member: FriendEntity? = nil,
        group: GroupEntity? = nil,
        expenses: [ExpenseEntity] = [],
        allMembers: [FriendEntity] = []
    ) {
        self.member = member
        self.group = group
        self.expenses = expenses
        self.allMembers = allMembers
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea(edges: .bottom)
            
            ScrollView {
                VStack(spacing: 24) {
                    Picker("Picker", selection: $selectedSegment) {
                        ForEach(SettlementSegment.allCases, id: \.self) {
                            Text($0.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.top, 16)
                    
                    if let summary = settlementSummary {
                        // Display transactions based on filter
                        let transactions = filteredTransactions(summary: summary)
                        
                        if transactions.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "checkmark.circle")
                                    .font(.system(size: 48))
                                    .foregroundColor(.green)
                                Text("All settled up!")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 60)
                        } else {
                            ForEach(transactions) { transaction in
                                Button(action: { paySheetIsPresented = true }) {
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
                                        title: isNeedToPayTransaction(transaction, summary: summary) ? "Need to Pay" : "Waiting For Payment",
                                        amount: transaction.amount,
                                        status: transaction.status,
                                        statusColor: transaction.isPaid ? .green : .red,
                                        personName: isNeedToPayTransaction(transaction, summary: summary) ? transaction.toMemberName : transaction.fromMemberName,
                                        personInitials: isNeedToPayTransaction(transaction, summary: summary) ? transaction.toMemberInitials : transaction.fromMemberInitials,
                                        expenseBreakdowns: transaction.relatedExpenses
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    } else {
                        ProgressView()
                            .padding(.top, 60)
                    }
                }
                .padding(.horizontal, 16)
                .sheet(isPresented: $paySheetIsPresented) {
                    PayNowView()
                }
            }
        }
        .navigationTitle(member?.fullName ?? "My Settlement")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        selectedFilter = "All"
                    } label: {
                        Label("All", systemImage: "list.bullet")
                    }
                    Button {
                        selectedFilter = "Need To Pay"
                    } label: {
                        Label("Need to pay", systemImage: "arrow.up.right")
                    }
                    Button {
                        selectedFilter = "Will Receive"
                    } label: {
                        Label("Will Receive", systemImage: "arrow.down.left")
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(selectedFilter)
                            .font(.system(size: 14, weight: .medium))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .foregroundStyle(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .onAppear {
            calculateSettlement()
        }
    }
    
    private func calculateSettlement() {
        guard let member = member else { return }
        
        settlementSummary = SettlementCalculator.calculateSettlementSummary(
            for: member.id ?? UUID(),
            memberName: member.fullName ?? "Unknown",
            memberInitials: member.avatarInitials,
            expenses: expenses,
            allMembers: allMembers
        )
    }
    
    private func filteredTransactions(summary: MemberSettlementSummary) -> [SettlementTransaction] {
        var transactions: [SettlementTransaction] = []
        
        switch selectedFilter {
        case "Need To Pay":
            transactions = summary.needToPay
        case "Will Receive":
            transactions = summary.waitingForPayment
        default:
            transactions = summary.needToPay + summary.waitingForPayment
        }
        
        // Filter by segment (Active/Done)
        return transactions.filter { transaction in
            selectedSegment == .active ? !transaction.isPaid : transaction.isPaid
        }
    }
    
    private func isNeedToPayTransaction(_ transaction: SettlementTransaction, summary: MemberSettlementSummary) -> Bool {
        return summary.needToPay.contains(where: { $0.id == transaction.id })
    }
}

// Enum Anda
enum SettlementSegment: String, CaseIterable {
    case active = "Active"
    case done = "Done"
}

#Preview {
    SettlementView()
}
