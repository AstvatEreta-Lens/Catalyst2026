//
//  ItemListCard.swift
//  Talangin
//
//  Created by Ali Jazzy Rasyid on 22/01/26.
//

import SwiftUI

struct ItemListCard: View {
    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Ngebakso")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fontWeight(.medium)
                
                Text("Rp 15.000")
                    .font(.body)
                    .fontWeight(.bold)
            }
            
            Spacer(minLength: 0)
            
            HStack(spacing: 6) {
                Text("CH")
                    .font(.footnote)
                    .foregroundStyle(.blue)
                    .frame(width: 40, height: 40)
                    .background(Color(UIColor.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Paid by")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("Chikmah")
                        .font(.callout)
                }
            }
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.tertiary)
        }
        .padding(16)
    }
}

#Preview {
    ItemListCard()
}
