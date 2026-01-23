//
//  ExpensesList.swift
//  OCR-Practice
//
//  Created by Ali Jazzy Rasyid on 20/01/26.
//

import SwiftUI

struct ExpensesList: View {
    let item: ExpenseDisplayItem
    let subtitle: String
    let amount: Double
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            let imageClipShape = RoundedRectangle(cornerRadius: 12, style: .continuous)
            
            Group {
                if let data = item.displayImageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    ZStack {
                        Color.gray.opacity(0.2)
                        Text(item.displayInitials)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(width: 40, height: 40)
            .clipShape(imageClipShape)
            .overlay(imageClipShape.strokeBorder(.quaternary, lineWidth: 0.5))
            .accessibility(hidden: true)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.displayName)
                    .font(.callout)
                    .fontWeight(.semibold)
                
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer(minLength: 0)
            
            Text(formatRupiah(amount))
                .font(.callout)
                .fontWeight(.semibold)
        }
        .font(.subheadline)
        .accessibilityElement(children: .combine)
    }
    
    private func formatRupiah(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "id_ID")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "Rp 0"
    }
}
