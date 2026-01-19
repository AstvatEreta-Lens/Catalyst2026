//
//  FriendDetailView.swift
//  Talangin
//
//  Created by Rifqi Rahman on 19/01/26.
//
//  Friend detail view showing profile header, payment account, and shared groups.
//  Displays comprehensive information about a contact/friend.
//
//  BACKEND DEVELOPER NOTES:
//  -------------------------
//  This view displays friend details. To integrate with backend:
//  1. Fetch contact details from API when view appears
//  2. Load payment methods from contact's shared data
//  3. Load shared groups by comparing group memberships
//  4. Consider caching contact details locally for offline access
//

import SwiftUI

struct FriendDetailView: View {
    
    // MARK: - Properties
    let contact: ContactEntity
    let sharedGroups: [GroupEntity]
    
    @State private var showPaymentSheet = false
    
    // MARK: - Mock Payment Methods
    /// BACKEND NOTE: Replace with contact.paymentMethods when integrated
    private var mockPaymentMethods: [ContactPaymentMethod] {
        [
            ContactPaymentMethod(
                providerName: "BCA",
                destination: "120-12038-00500",
                holderName: contact.fullName,
                isPrimary: true
            ),
            ContactPaymentMethod(
                providerName: "GoPay",
                destination: "081234568887",
                holderName: contact.fullName,
                isPrimary: false
            )
        ]
    }
    
    /// Default payment method to display
    private var primaryPayment: ContactPaymentMethod? {
        mockPaymentMethods.first { $0.isPrimary } ?? mockPaymentMethods.first
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // MARK: - Gradient Header
                GradientHeaderView(
                    photoData: contact.profilePhotoData,
                    initials: contact.initials,
                    name: contact.fullName,
                    subtitle: contact.email
                )
                
                // MARK: - Content
                VStack(spacing: 0) {
                    // Payment Account Section
                    paymentAccountSection
                    
                    // Shared Groups Section
                    if !sharedGroups.isEmpty {
                        sharedGroupsSection
                    }
                }
                .padding(.top, AppSpacing.md)
            }
        }
        .background(Color(.systemGroupedBackground))
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("") // Empty title since header shows name
            }
        }
        .sheet(isPresented: $showPaymentSheet) {
            FriendPaymentAccountSheet(
                contactName: contact.fullName,
                paymentMethods: mockPaymentMethods
            )
        }
    }
    
    // MARK: - Payment Account Section
    private var paymentAccountSection: some View {
        VStack(spacing: 0) {
            // Section Header
            ProfileSectionHeader(title: "PAYMENT ACCOUNT")
            
            // Payment Row
            Button {
                showPaymentSheet = true
            } label: {
                HStack {
                    Text(primaryPayment?.providerName ?? "No payment method")
                        .font(.Body)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.vertical, AppSpacing.md)
                .background(Color(.systemBackground))
            }
        }
    }
    
    // MARK: - Shared Groups Section
    private var sharedGroupsSection: some View {
        VStack(spacing: 0) {
            // Section Header
            ProfileSectionHeader(title: "SHARED GROUP")
            
            // Groups List
            VStack(spacing: 0) {
                ForEach(Array(sharedGroups.enumerated()), id: \.element.id) { index, group in
                    NavigationLink {
                        GroupDetailView(group: group)
                    } label: {
                        SharedGroupRow(group: group)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    if index < sharedGroups.count - 1 {
                        Divider()
                            .padding(.leading, AppSpacing.lg + 40 + AppSpacing.md)
                    }
                }
            }
            .background(Color(.systemBackground))
        }
    }
}

// MARK: - Shared Group Row

private struct SharedGroupRow: View {
    let group: GroupEntity
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            // Group Icon
            GroupIconView(group: group, size: .small)
            
            // Group Name
            Text(group.name)
                .font(.Body)
                .foregroundColor(.primary)
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.md)
    }
}

#Preview {
    NavigationStack {
        FriendDetailView(
            contact: ContactEntity.mockContactWithPayments(),
            sharedGroups: Array(GroupEntity.mockGroups.prefix(2))
        )
    }
}
