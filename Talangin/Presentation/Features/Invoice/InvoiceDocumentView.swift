//
//  InvoiceDocumentView.swift
//  Talangin
//
//  Created by System on 26/01/26.
//

import SwiftUI

/// A4-sized invoice document view for group settlement summary
/// Optimised for single-page high-density data.
struct InvoiceDocumentView: View {
    let group: GroupEntity
    let memberSettlements: [(member: FriendEntity, summary: MemberSettlementSummary)]
    let generatedDate: Date
    
    // A4 dimensions in points
    private let pageWidth: CGFloat = 595
    private let pageHeight: CGFloat = 842
    private let margin: CGFloat = 40
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.white
            
            VStack(spacing: 0) {
                // Top accent bar
                LinearGradient(
                    colors: [Color(red: 0.17, green: 0.28, blue: 0.7), Color(red: 0.09, green: 0.71, blue: 0.28)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 8)
                
                VStack(alignment: .leading, spacing: 20) {
                    headerSection
                        .padding(.top, 20)
                    
                    summaryCards
                    
                    tableHeader
                        .padding(.top, 10)
                    
                    // List all members
                    VStack(spacing: 0) {
                        ForEach(memberSettlements.indices, id: \.self) { index in
                            memberRow(memberSettlements[index])
                            
                            if index < memberSettlements.count - 1 {
                                Divider()
                                    .background(Color.gray.opacity(0.2))
                            }
                        }
                    }
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                    )
                    
                    Spacer()
                    
                    footerSection
                }
                .padding(.horizontal, margin)
                .padding(.bottom, margin)
            }
        }
        .frame(width: pageWidth, height: pageHeight)
    }
    
    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(LinearGradient(colors: [.blue, .green], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 20))
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("TALANGIN")
                            .font(.system(size: 20, weight: .black))
                            .tracking(2)
                        Text("Expense Sharing Simplified")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                Text(group.name ?? "Untitled Group")
                    .font(.system(size: 28, weight: .bold))
                    .padding(.top, 12)
                
                Text("Settlement Report • \(memberSettlements.count) Members")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("INVOICE")
                    .font(.system(size: 32, weight: .thin))
                    .foregroundColor(.gray)
                
                Text("Date: \(generatedDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var summaryCards: some View {
        HStack(spacing: 15) {
            summaryCard(
                title: "Total Expenses",
                value: formatCurrency(memberSettlements.map { $0.summary.totalWaitingForPayment }.reduce(0, +)),
                color: .blue
            )
            summaryCard(
                title: "Active Debts",
                value: "\(memberSettlements.filter { !$0.summary.needToPay.isEmpty }.count) People",
                color: .red
            )
            summaryCard(
                title: "Status",
                value: "In Progress",
                color: .orange
            )
        }
    }
    
    private func summaryCard(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(color.opacity(0.05))
        .cornerRadius(10)
    }
    
    private var tableHeader: some View {
        HStack(spacing: 0) {
            Text("MEMBER")
                .font(.system(size: 11, weight: .bold))
                .frame(width: 140, alignment: .leading)
            Text("STATUS / BALANCE")
                .font(.system(size: 11, weight: .bold))
                .frame(width: 180, alignment: .leading)
            Text("INSTRUCTIONS / DETAILS")
                .font(.system(size: 11, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(6)
    }
    
    private func memberRow(_ data: (member: FriendEntity, summary: MemberSettlementSummary)) -> some View {
        HStack(alignment: .top, spacing: 0) {
            // Member column
            VStack(alignment: .leading, spacing: 4) {
                Text(data.member.fullName ?? "Unknown")
                    .font(.system(size: 13, weight: .bold))
                Text(data.member.email ?? "-")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            .frame(width: 140, alignment: .leading)
            
            // Status/Balance column
            VStack(alignment: .leading, spacing: 8) {
                if data.summary.totalWaitingForPayment > 0 {
                    balanceLabel(title: "Wating for", amount: data.summary.totalWaitingForPayment, color: .green, icon: "arrow.down.left")
                }
                if data.summary.totalNeedToPay > 0 {
                    balanceLabel(title: "Needs to pay", amount: data.summary.totalNeedToPay, color: .red, icon: "arrow.up.right")
                }
                if data.summary.totalWaitingForPayment == 0 && data.summary.totalNeedToPay == 0 {
                    Text("Settled Up")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.gray)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(4)
                }
            }
            .frame(width: 180, alignment: .leading)
            
            // Instructions column
            VStack(alignment: .leading, spacing: 4) {
                ForEach(data.summary.needToPay.prefix(3)) { transaction in
                    Text("Pay \(formatCurrency(transaction.amount)) to \(transaction.toMemberName)")
                        .font(.system(size: 10))
                        .foregroundColor(.primary)
                }
                if data.summary.needToPay.count > 3 {
                    Text("+ \(data.summary.needToPay.count - 3) more transactions")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                }
                
                if data.summary.needToPay.isEmpty && !data.summary.waitingForPayment.isEmpty {
                    Text("Expecting payment from \(data.summary.waitingForPayment.count) people")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
    
    private func balanceLabel(title: String, amount: Double, color: Color, icon: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 9, weight: .bold))
            Text(title)
                .font(.system(size: 10))
            Text(formatCurrency(amount))
                .font(.system(size: 11, weight: .bold))
        }
        .foregroundColor(color)
    }
    
    private var footerSection: some View {
        VStack(spacing: 12) {
            Divider()
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Notice")
                        .font(.system(size: 11, weight: .bold))
                    Text("This is an automated settlement summary. Please verify amounts in the Talangin app before making payments.")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Generated via")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                    Text("Talangin App v1.0")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.blue)
                }
            }
        }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.maximumFractionDigits = 0
        return "Rp " + (formatter.string(from: NSNumber(value: amount)) ?? "0")
    }
}

#Preview {
    InvoiceDocumentView(
        group: GroupEntity.mockGroups[0],
        memberSettlements: [],
        generatedDate: Date()
    )
}
