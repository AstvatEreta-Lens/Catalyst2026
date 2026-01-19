//
//  AddPaymentMethodButton.swift
//  Talangin
//
//  Created by Rifqi Rahman on 15/01/26.
//
//  Button component for adding a new payment method option.
//

import SwiftUI

struct AddPaymentMethodButton: View {
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(AppColors.success)

                Text("Add Another Option")
                    .foregroundColor(.primary)
                    .font(.Body)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)
            .background(Color(.systemBackground))
        }
    }
}

#Preview {
    AddPaymentMethodButton {
        print("Add payment method tapped")
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
