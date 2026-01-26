//
//  SettlementCard.swift
//  Talangin
//
//  Created by Ali Jazzy Rasyid on 23/01/26.
//

import SwiftUI

struct SettlementCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Need to Pay")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                
                HStack{
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.right")
                            .font(.body)
                            .foregroundStyle(.red)
                        
                        Text(formatRupiah(30000))
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                    
                    Text("Unpaid")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .foregroundStyle(.red)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(6)
                }
            }
            
            Divider()
            
            HStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(UIColor.systemGray6))
                        .frame(width: 40, height: 40)
                    Text("CH")
                        .font(.footnote)
                        .foregroundStyle(.blue)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("to")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("Chikmah")
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
