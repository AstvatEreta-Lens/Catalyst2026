//
//  PaymentMethodEmptyStateView.swift
//  Talangin
//
//  Created by Rifqi Rahman on 19/01/26.
//
//  Empty state view shown when user has no payment methods or user data is unavailable.
//

import SwiftUI

struct PaymentMethodEmptyStateView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()
            
            // Icon
            Image(systemName: "creditcard.fill")
                .font(.system(size: 60))
                .foregroundColor(.secondary.opacity(0.5))
            
            // Title
            Text("No Payment Methods")
                .font(.Title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            // Description
            Text("Add a payment method to receive money from your friends when splitting bills.")
                .font(.Body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.xl)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Payment Account")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        PaymentMethodEmptyStateView()
    }
}
