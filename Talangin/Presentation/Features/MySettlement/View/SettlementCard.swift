//
//  SettlementCard.swift
//  Talangin
//
//  Created by Ali Jazzy Rasyid on 23/01/26.
//

import SwiftUI

struct SettlementCard: View {
    let title: String
    let amount: Double
    let status: String
    let statusColor: Color
    let personName: String
    let personInitials: String
    
    init(
        title: String = "Need to Pay",
        amount: Double = 30000,
        status: String = "Unpaid",
        statusColor: Color = .red,
        personName: String = "Chikmah",
        personInitials: String = "CH"
    ) {
        self.title = title
        self.amount = amount
        self.status = status
        self.statusColor = statusColor
        self.personName = personName
        self.personInitials = personInitials
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                
                HStack{
                    HStack(spacing: 4) {
                        Image(systemName: title.contains("Pay") ? "arrow.up.right" : "arrow.down.left")
                            .font(.body)
                            .foregroundStyle(title.contains("Pay") ? .red : .green)
                        
                        Text(formatRupiah(amount))
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                    
                    Text(status)
                        .font(.footnote)
                        .fontWeight(.medium)
                        .foregroundStyle(statusColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(statusColor.opacity(0.1))
                        .cornerRadius(6)
                }
            }
            
            Divider()
            
            HStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(UIColor.systemGray6))
                        .frame(width: 40, height: 40)
                    Text(personInitials)
                        .font(.footnote)
                        .foregroundStyle(.blue)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title.contains("Pay") ? "to" : "from")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(personName)
                        .font(.callout)
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    private func formatRupiah(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        return "Rp " + (formatter.string(from: NSNumber(value: amount)) ?? "0")
    }
}

#Preview {
    SettlementCard()
}
