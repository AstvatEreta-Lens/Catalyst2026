//
//  SettlementDetailView.swift
//  Talangin
//
//  Created by Ali Jazzy Rasyid on 22/01/26.
//

import SwiftUI

struct GroupDetailCard: View {
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            HStack (spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.orange.opacity(0.1))
                        .frame(width: 40, height: 40)
                    Text("🚀")
                        .font(.callout)
                }
                
                Text("Arisan Ibu Gang 2")
                    .font(.callout)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .foregroundStyle(.secondary)
            }
            .padding(EdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12))
            
            Text("11 Dec 2025")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)
            
            VStack(spacing: 0) {
                ItemListCard()
                Divider()
                ItemListCard()
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(EdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12))
    }
}

#Preview {
    GroupDetailCard()
}
