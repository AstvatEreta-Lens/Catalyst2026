//
//  PaymentSectionHeader.swift
//  Talangin
//
//  Created by Rifqi Rahman on 15/01/26.
//
//  Section header component for payment account sections with Edit button.
//

import SwiftUI

struct PaymentSectionHeader: View {
    let title: String
    let onEditTapped: () -> Void

    var body: some View {
        HStack {
            Text(title)
                .font(.Caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)

            Spacer()

            Button {
                onEditTapped()
            } label: {
                Text("Edit")
                    .font(.Body)
                    .foregroundColor(AppColors.primary)
            }
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.top, AppSpacing.md)
        .padding(.bottom, AppSpacing.xs)
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    PaymentSectionHeader(title: "PAYMENT ACCOUNT") {
        print("Edit tapped")
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
