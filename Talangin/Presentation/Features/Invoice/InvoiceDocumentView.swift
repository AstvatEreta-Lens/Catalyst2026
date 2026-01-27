//
//  InvoiceDocumentView.swift
//  Talangin
//
//  Created by System on 26/01/26.
//

import SwiftUI

/// A4-sized invoice document view for group settlement summary
struct InvoiceDocumentView: View {
    let group: GroupEntity
    let memberSettlements: [(member: FriendEntity, summary: MemberSettlementSummary)]
    let generatedDate: Date
    
    // A4 dimensions in points
    private let pageWidth: CGFloat = 595
    private let pageHeight: CGFloat = 842
    private let margin: CGFloat = 40
    
    var body: some View {
        VStack(spacing: 0) {
            // Calculate how many members fit per page
            let membersPerPage = 3 // Adjust based on content height
            let pageCount = Int(ceil(Double(memberSettlements.count) / Double(membersPerPage)))
            
            ForEach(0..<pageCount, id: \.self) { pageIndex in
                invoicePage(
                    pageIndex: pageIndex,
                    membersPerPage: membersPerPage
                )
                .frame(width: pageWidth, height: pageHeight)
            }
        }
    }
 
      
    
    @ViewBuilder
    private func invoicePage(pageIndex: Int, membersPerPage: Int) -> some View {
        ZStack(alignment: .top) {
            // Background
            Color.white
            
            VStack(spacing: 0) {
                // Header with gradient (only on first page)
                if pageIndex == 0 {
                    LinearGradient(
                        stops: [
                            Gradient.Stop(color: Color(red: 0.17, green: 0.28, blue: 0.7), location: 0.00),
                            Gradient.Stop(color: Color(red: 0.12, green: 0.54, blue: 0.48), location: 0.82),
                            Gradient.Stop(color: Color(red: 0.09, green: 0.71, blue: 0.28), location: 1.00),
                        ],
                        startPoint: UnitPoint(x: 0.02, y: 0),
                        endPoint: UnitPoint(x: 1, y: 1.04)
                    )
               
                    .frame(height: 60)
                }
                
                VStack(alignment: .leading, spacing: 24) {
                    // Header section (only on first page)
                    if pageIndex == 0 {
                        headerSection
                    }
                    
                    // Table header
                    tableHeader
                    
                    // Member rows for this page
                    let startIndex = pageIndex * membersPerPage
                    let endIndex = min(startIndex + membersPerPage, memberSettlements.count)
                    
                    ForEach(startIndex..<endIndex, id: \.self) { index in
                        memberRow(memberSettlements[index])
                        
                        if index < endIndex - 1 {
                            Divider()
                                .background(Color.gray.opacity(0.3))
                        }
                    }
                    
                    Spacer()
                    
                    // Footer (only on last page)
                    if pageIndex == pageCount - 1 {
                        footerSection
                    }
                }
                .padding(margin)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                // App logo/icon
                ZStack {
                    //                    RoundedRectangle(cornerRadius: 12)
                    //                        .fill(Color.gray.opacity(0.2))
                    //                        .frame(width: 60, height: 60)
                    
                    Image("AppIconImage")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Talangin")
                        .font(.system(size: 24, weight: .bold))
                    
                    Text("Settlement Invoice")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("Invoice")
                    .font(.system(size: 36, weight: .bold))
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Group Name")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 6) {
                        Text(group.name ?? "Untitled Group")
                            .font(.system(size: 18, weight: .bold))
                        
                        if let iconName = group.iconName {
                            Image(systemName: iconName)
                                .font(.system(size: 16))
                        }
                    }
                    
                    Text("\(memberSettlements.count) members")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text("Last Updated")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    Text(generatedDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.system(size: 16, weight: .semibold))
                }
            }
        }
    }
    
    private var tableHeader: some View {
        HStack(spacing: 16) {
            Text("Name")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(red: 0.24, green: 0.47, blue: 0.76))
                .frame(width: 120, alignment: .leading)
            
            Text("Status")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(red: 0.24, green: 0.47, blue: 0.76))
                .frame(width: 150, alignment: .leading)
            
            Text("Details")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(red: 0.24, green: 0.47, blue: 0.76))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            Color(red: 0.84, green: 0.93, blue: 0.96)
        )
        .cornerRadius(8)
    }
    
    private func memberRow(_ data: (member: FriendEntity, summary: MemberSettlementSummary)) -> some View {
        HStack(alignment: .top, spacing: 16) {
            // Name column
            Text(data.member.fullName ?? "Unknown")
                .font(.system(size: 14, weight: .medium))
                .frame(width: 120, alignment: .leading)
            
            // Status column
            VStack(alignment: .leading, spacing: 8) {
                if !data.summary.waitingForPayment.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.down.left")
                            .font(.system(size: 12))
                            .foregroundColor(.green)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Waiting for Payment")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            
                            Text(formatCurrency(data.summary.totalWaitingForPayment))
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.green)
                        }
                    }
                }
                
                if !data.summary.needToPay.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Need to Pay")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            
                            Text(formatCurrency(data.summary.totalNeedToPay))
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.red)
                        }
                    }
                }
                
                if data.summary.waitingForPayment.isEmpty && data.summary.needToPay.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 12))
                            .foregroundColor(.green)
                        
                        Text("Settled")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(width: 150, alignment: .leading)
            
            // Details column
            VStack(alignment: .leading, spacing: 6) {
                // Waiting for payment details
                if !data.summary.waitingForPayment.isEmpty {
                    ForEach(data.summary.waitingForPayment.prefix(3)) { transaction in
                        HStack {
                            Text("From")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                            
                            Text(transaction.fromMemberName)
                                .font(.system(size: 11, weight: .medium))
                            
                            Spacer()
                            
                            Text(formatCurrency(transaction.amount))
                                .font(.system(size: 11, weight: .semibold))
                        }
                    }
                    
                    if data.summary.waitingForPayment.count > 3 {
                        Text("+ \(data.summary.waitingForPayment.count - 3) more")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
                
                // Need to pay details
                if !data.summary.needToPay.isEmpty {
                    if !data.summary.waitingForPayment.isEmpty {
                        Divider()
                            .padding(.vertical, 4)
                    }
                    
                    ForEach(data.summary.needToPay.prefix(3)) { transaction in
                        HStack {
                            Text("To")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                            
                            Text(transaction.toMemberName)
                                .font(.system(size: 11, weight: .medium))
                            
                            Spacer()
                            
                            Text(formatCurrency(transaction.amount))
                                .font(.system(size: 11, weight: .semibold))
                        }
                    }
                    
                    if data.summary.needToPay.count > 3 {
                        Text("+ \(data.summary.needToPay.count - 3) more")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
    
    private var footerSection: some View {
        VStack(spacing: 4) {
            Divider()
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Note")
                    .font(.system(size: 12, weight: .bold))
                
                Text("To view expense details, open the Talangin app.")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Text("Generated on \(generatedDate.formatted(date: .long, time: .shortened))")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Talangin")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Color(red: 60/255, green: 121/255, blue: 195/255))
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
    
    private var pageCount: Int {
        let membersPerPage = 3
        return Int(ceil(Double(memberSettlements.count) / Double(membersPerPage)))
    }
}

#Preview {
    let mockGroup = GroupEntity(
        name: "Trip To Bromo",
        iconName: "car.fill"
    )
    
    let mockMembers = [
        FriendEntity(id: UUID(), userId: "1", fullName: "John Doe", email: nil, phoneNumber: nil, profilePhotoData: nil),
        FriendEntity(id: UUID(), userId: "2", fullName: "Chikmah", email: nil, phoneNumber: nil, profilePhotoData: nil),
        FriendEntity(id: UUID(), userId: "3", fullName: "Fida Afifah", email: nil, phoneNumber: nil, profilePhotoData: nil)
    ]
    
    let mockSettlements: [(FriendEntity, MemberSettlementSummary)] = mockMembers.map { member in
        (member, MemberSettlementSummary(
            memberID: member.id ?? UUID(),
            memberName: member.fullName ?? "",
            memberInitials: member.avatarInitials,
            needToPay: [],
            waitingForPayment: []
        ))
    }
    
    InvoiceDocumentView(
        group: mockGroup,
        memberSettlements: mockSettlements,
        generatedDate: Date()
    )
}
