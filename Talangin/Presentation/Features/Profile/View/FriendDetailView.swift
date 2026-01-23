//
//  FriendDetailView.swift
//  Talangin
//
//  Created by Rifqi Rahman on 19/01/26.
//
//  Friend detail view using native SwiftUI List component.
//  Shows profile header, payment account, and shared groups.
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
        List {
            // MARK: - Profile Header
            Section {
                GradientHeaderView(
                    photoData: contact.profilePhotoData,
                    initials: contact.initials,
                    name: contact.fullName,
                    subtitle: contact.email
                )
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }
            
            // MARK: - Payment Account Section
            Section {
                Button {
                    showPaymentSheet = true
                } label: {
                    HStack {
                        Text(primaryPayment?.providerName ?? "No payment method")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
            } header: {
                Text("PAYMENT ACCOUNT")
            }
            
            // MARK: - Shared Groups Section
            if !sharedGroups.isEmpty {
                Section {
                    ForEach(sharedGroups) { group in
                        NavigationLink {
                            GroupDetailView(group: group)
                        } label: {
                            HStack(spacing: AppSpacing.md) {
                                GroupIconView(group: group, size: .small)
                                Text(group.name)
                            }
                        }
                    }
                } header: {
                    Text("SHARED GROUPS")
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPaymentSheet) {
            FriendPaymentAccountSheet(
                contactName: contact.fullName,
                paymentMethods: mockPaymentMethods
            )
        }
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
