//
//  PaymentMethodListView.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 07/01/26.
//
//  Payment account list view using native SwiftUI List component.
//  Displays default and other payment methods with native section headers.
//
//  BACKEND DEVELOPER NOTES:
//  -------------------------
//  This view displays PaymentMethodEntity data:
//  1. Sorted by isDefault (default method first)
//  2. Each row navigates to EditPaymentMethodView
//  3. Add button presents AddPaymentMethodView sheet
//

import SwiftUI
import SwiftData

struct PaymentMethodListView: View {
    let methods: [PaymentMethodEntity]
    let user: UserEntity

    @State private var showAddPaymentMethod = false
    
    // MARK: - Computed Properties
    private var defaultMethod: PaymentMethodEntity? {
        methods.first { $0.isDefault } ?? methods.first
    }

    private var otherMethods: [PaymentMethodEntity] {
        if let defaultMethod = defaultMethod {
            return methods.filter { $0.id != defaultMethod.id }
        }
        return Array(methods.dropFirst())
    }

    var body: some View {
        List {
            // MARK: - Default Payment Account
            if let defaultMethod = defaultMethod {
                Section {
                    NavigationLink {
                        EditPaymentMethodView(method: defaultMethod)
                    } label: {
                        PaymentMethodCell(
                            providerName: defaultMethod.providerName,
                            destination: defaultMethod.destination,
                            holderName: defaultMethod.holderName,
                            isDefault: defaultMethod.isDefault
                        )
                    }
                } header: {
                    Text("PAYMENT ACCOUNT")
                }
            }

            // MARK: - Other Accounts
            if !otherMethods.isEmpty {
                Section {
                    ForEach(otherMethods) { method in
                        NavigationLink {
                            EditPaymentMethodView(method: method)
                        } label: {
                            PaymentMethodCell(
                                providerName: method.providerName,
                                destination: method.destination,
                                holderName: method.holderName,
                                isDefault: method.isDefault
                            )
                        }
                    }
                } header: {
                    Text("ANOTHER ACCOUNT")
                }
            }

            // MARK: - Add Another Option
            Section {
                Button {
                    showAddPaymentMethod = true
                } label: {
                    HStack(spacing: AppSpacing.sm) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppColors.success)
                        
                        Text("Add Another Option")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Payment Account")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showAddPaymentMethod) {
            AddPaymentMethodView(user: user)
        }
    }
}

// MARK: - Payment Method Cell

private struct PaymentMethodCell: View {
    let providerName: String
    let destination: String
    let holderName: String
    let isDefault: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            // Provider Name with badge
            HStack {
                Text(providerName)
                    .font(.Body)
                    .fontWeight(.medium)
                
                if isDefault {
                    Text("Default")
                        .font(.Caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, AppSpacing.xs)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(AppColors.accentWater)
                        )
                }
            }
            
            // Account Number
            Text(destination)
                .font(.Subheadline)
                .foregroundColor(.secondary)
            
            // Holder Name
            if !holderName.isEmpty {
                Text(holderName)
                    .font(.Subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, AppSpacing.xs)
    }
}

#Preview {
    PaymentMethodListPreview()
}

@MainActor
private struct PaymentMethodListPreview: View {
    @State private var container: ModelContainer?
    @State private var methods: [PaymentMethodEntity] = []
    @State private var user: UserEntity?
    @State private var hasError = false
    
    var body: some View {
        Group {
            if hasError {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text("Preview Error")
                        .font(.headline)
                }
            } else if let container = container, let user = user {
                NavigationStack {
                    PaymentMethodListView(methods: methods, user: user)
                        .modelContainer(container)
                }
            } else {
                ProgressView()
                    .onAppear { setupPreview() }
            }
        }
    }
    
    private func setupPreview() {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let newContainer = try ModelContainer(
                for: Item.self, UserEntity.self, PaymentMethodEntity.self,
                configurations: config
            )

            let mockUser = UserEntity(appleUserId: "preview")
            let method1 = PaymentMethodEntity(
                providerName: "BCA",
                destination: "120-12038-19333",
                holderName: "Rifqi Smith",
                isDefault: true,
                user: mockUser
            )
            let method2 = PaymentMethodEntity(
                providerName: "GoPay",
                destination: "081234566767",
                holderName: "Rifqi Smith",
                isDefault: false,
                user: mockUser
            )

            let context = newContainer.mainContext
            context.insert(mockUser)
            context.insert(method1)
            context.insert(method2)
            
            self.container = newContainer
            self.user = mockUser
            self.methods = [method1, method2]
        } catch {
            hasError = true
        }
    }
}
