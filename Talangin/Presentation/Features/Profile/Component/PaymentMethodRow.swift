//
//  PaymentMethodRow.swift
//  Talangin
//
//  Created by Rifqi Rahman on 15/01/26.
//
//  Payment method row component displaying bank/wallet name, number, and holder name.
//

import SwiftUI

struct PaymentMethodRow: View {
    let providerName: String
    let destination: String
    let holderName: String
    let isDefault: Bool

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Provider Name with Default Badge
            HStack {
                Text(providerName)
                    .foregroundColor(.primary)
                    .font(.Body)
                Spacer()
                if isDefault {
                    Text("Default")
                        .font(.Caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, AppSpacing.xs)
                        .padding(.vertical, AppSpacing.xxs)
                        .background(
                            Capsule()
                                .fill(AppColors.accentWater)
                        )
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)

            Divider()
                .padding(.leading, AppSpacing.lg)

            // MARK: - Account Number
            HStack {
                Text(destination)
                    .foregroundColor(.primary)
                    .font(.Body)
                Spacer()
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)

            Divider()
                .padding(.leading, AppSpacing.lg)

            // MARK: - Holder Name
            HStack {
                Text(holderName.isEmpty ? "-" : holderName)
                    .foregroundColor(.primary)
                    .font(.Body)
                Spacer()
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)
        }
        .background(Color(.systemBackground))
    }
}

#Preview {
    VStack(spacing: 0) {
        PaymentMethodRow(
            providerName: "BCA",
            destination: "120-12038-19333",
            holderName: "Rifqi Smith",
            isDefault: true
        )
        
        PaymentMethodRow(
            providerName: "GoPay",
            destination: "081234566767",
            holderName: "Rifqi Smith",
            isDefault: false
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
