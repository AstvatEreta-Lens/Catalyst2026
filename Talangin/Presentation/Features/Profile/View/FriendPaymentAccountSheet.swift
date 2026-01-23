//
//  FriendPaymentAccountSheet.swift
//  Talangin
//
//  Created by Rifqi Rahman on 19/01/26.
//
//  Sheet view displaying friend's payment accounts with search and copy functionality.
//  Allows users to view and copy payment information for transfers.
//
//  BACKEND DEVELOPER NOTES:
//  -------------------------
//  This sheet displays a friend's shared payment methods.
//  Security considerations:
//  1. Only show payment methods the friend has explicitly shared
//  2. Consider masking sensitive portions of account numbers
//  3. Log copy actions for audit purposes (optional)
//  4. Implement rate limiting on payment info access if needed
//

import SwiftUI

struct FriendPaymentAccountSheet: View {
    
    // MARK: - Properties
    let contactName: String
    let paymentMethods: [ContactPaymentMethod]
    
    @Environment(\.dismiss) private var dismiss
    @State private var searchText: String = ""
    @State private var showCopiedToast = false
    @State private var copiedText: String = ""
    
    // MARK: - Computed Properties
    
    private var primaryMethod: ContactPaymentMethod? {
        paymentMethods.first { $0.isPrimary }
    }
    
    private var otherMethods: [ContactPaymentMethod] {
        paymentMethods.filter { !$0.isPrimary }
    }
    
    private var filteredPrimaryMethod: ContactPaymentMethod? {
        guard !searchText.isEmpty else { return primaryMethod }
        guard let primary = primaryMethod else { return nil }
        return matchesSearch(primary) ? primary : nil
    }
    
    private var filteredOtherMethods: [ContactPaymentMethod] {
        guard !searchText.isEmpty else { return otherMethods }
        return otherMethods.filter { matchesSearch($0) }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Main Content
                VStack(spacing: 0) {
                    // MARK: - Search Bar
                    searchBar
                    
                    // MARK: - Payment Methods List
                    ScrollView {
                        VStack(spacing: 0) {
                            // Primary Account Section
                            if let primary = filteredPrimaryMethod {
                                PaymentAccountSection(
                                    title: "PRIMARY ACCOUNT",
                                    methods: [primary],
                                    onCopy: copyToClipboard
                                )
                            }
                            
                            // Other Accounts Section
                            if !filteredOtherMethods.isEmpty {
                                PaymentAccountSection(
                                    title: "ANOTHER ACCOUNT",
                                    methods: filteredOtherMethods,
                                    onCopy: copyToClipboard
                                )
                            }
                            
                            // Empty State
                            if filteredPrimaryMethod == nil && filteredOtherMethods.isEmpty {
                                emptyStateView
                            }
                        }
                        .padding(.top, AppSpacing.sm)
                    }
                }
                .background(Color(.systemGroupedBackground))
                
                // MARK: - Copied Toast
                if showCopiedToast {
                    VStack {
                        Spacer()
                        copiedToastView
                            .padding(.bottom, AppSpacing.xl)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(response: 0.3), value: showCopiedToast)
                }
            }
            .navigationTitle(contactName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search name", text: $searchText)
                .font(.Body)
            
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
            
            Button {
                // BACKEND NOTE: Implement speech recognition
            } label: {
                Image(systemName: "mic.fill")
                    .foregroundColor(AppColors.primary)
            }
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.md)
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            
            Text("No results found")
                .font(.Headline)
                .foregroundColor(.secondary)
            
            Text("Try a different search term")
                .font(.Subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.xxxl)
    }
    
    // MARK: - Copied Toast
    private var copiedToastView: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.white)
            
            Text("Copied: \(copiedText)")
                .font(.Subheadline)
                .foregroundColor(.white)
                .lineLimit(1)
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.sm)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.8))
        )
    }
    
    // MARK: - Helper Methods
    
    private func matchesSearch(_ method: ContactPaymentMethod) -> Bool {
        method.providerName.localizedCaseInsensitiveContains(searchText) ||
        method.destination.localizedCaseInsensitiveContains(searchText) ||
        method.holderName.localizedCaseInsensitiveContains(searchText)
    }
    
    private func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
        copiedText = text
        
        withAnimation {
            showCopiedToast = true
        }
        
        // Hide toast after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showCopiedToast = false
            }
        }
    }
}

// MARK: - Payment Account Section

private struct PaymentAccountSection: View {
    let title: String
    let methods: [ContactPaymentMethod]
    let onCopy: (String) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Section Header
            HStack {
                Text(title)
                    .font(.Caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.md)
            .padding(.bottom, AppSpacing.xs)
            
            // Methods
            VStack(spacing: 0) {
                ForEach(Array(methods.enumerated()), id: \.element.id) { index, method in
                    PaymentMethodCard(method: method, onCopy: onCopy)
                    
                    if index < methods.count - 1 {
                        Divider()
                            .padding(.leading, AppSpacing.lg)
                    }
                }
            }
            .background(Color(.systemBackground))
        }
    }
}

// MARK: - Payment Method Card

private struct PaymentMethodCard: View {
    let method: ContactPaymentMethod
    let onCopy: (String) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Provider Name Row
            HStack {
                Text(method.providerName)
                    .font(.Body)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)
            .contentShape(Rectangle())
            .onTapGesture {
                onCopy(method.providerName)
            }
            
            Divider()
                .padding(.leading, AppSpacing.lg)
            
            // Account Number Row (Copyable)
            HStack {
                Text(method.destination)
                    .font(.Body)
                    .foregroundColor(.primary)
                Spacer()
                
                Button {
                    onCopy(method.destination)
                } label: {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.primary)
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)
            .contentShape(Rectangle())
            .onTapGesture {
                onCopy(method.destination)
            }
            
            Divider()
                .padding(.leading, AppSpacing.lg)
            
            // Holder Name Row
            HStack {
                Text(method.holderName)
                    .font(.Body)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)
            .contentShape(Rectangle())
            .onTapGesture {
                onCopy(method.holderName)
            }
        }
    }
}

#Preview {
    FriendPaymentAccountSheet(
        contactName: "Sari Yulia",
        paymentMethods: [
            ContactPaymentMethod(
                providerName: "BCA",
                destination: "120-12038-00500",
                holderName: "Sari Yulia",
                isPrimary: true
            ),
            ContactPaymentMethod(
                providerName: "GoPay",
                destination: "081234568887",
                holderName: "Sari Yulia",
                isPrimary: false
            )
        ]
    )
}
