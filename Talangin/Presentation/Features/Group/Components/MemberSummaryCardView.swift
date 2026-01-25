//
//  MemberSummaryCardView.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 25/01/26.
//

import SwiftUI

struct MemberSummaryCardView: View {
    let member: FriendEntity
    let currentUserID: UUID
    let youNeedToPay: Double
    let waitingForPayment: Double
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color(uiColor: .systemGray6))
                        .frame(width: 44, height: 44)
                    Text(member.avatarInitials)
                        .font(.system(size: 14, weight: .bold))
                }
                
                Text("\(member.fullName ?? "Unknown")\(member.id == currentUserID ? " (Me)" : "")")
                    .font(.system(size: 18, weight: .bold))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary.opacity(0.5))
            }
            
            HStack(spacing: 0) {
                // You Need To Pay
                VStack(alignment: .leading, spacing: 6) {
                    Text("You Need To Pay")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.red)
                        
                        Text(formatCurrency(youNeedToPay))
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                    }
                }
                
                Spacer()
                
                // Waiting For Payment
                VStack(alignment: .leading, spacing: 6) {
                    Text("Waiting For Payment")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.down.left")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.green)
                        
                        Text(formatCurrency(waitingForPayment))
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "Rp"
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "Rp 0"
    }
}
