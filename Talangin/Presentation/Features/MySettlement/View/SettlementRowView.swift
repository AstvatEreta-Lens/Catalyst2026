//
//  SettlementCardView.swift
//  Talangin
//
//  Created by Ali Jazzy Rasyid on 22/01/26.
//

import SwiftUI

struct SettlementRowView: View {

    @Binding var isExpanded: Bool
    var onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            
            SettlementCard()
            .zIndex(1)
            // -- Footer See Details --
            VStack(spacing: 0) {
                Button(action: onTap) {
                    HStack {
                        Text("See Details")
                            .font(.footnote)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    }
                    .padding()
                    .foregroundStyle(.blue)
                }
                
                if isExpanded {
                    VStack(spacing: 24){
                        GroupDetailCard()
                        GroupDetailCard()
                    }
                }
            }
            .background(Color.blue.opacity(0.1))
            .clipShape(
                UnevenRoundedRectangle(
                    bottomLeadingRadius: 12,
                    bottomTrailingRadius: 12
                )
            )
            .offset(y: -6)
        }
    }
}

