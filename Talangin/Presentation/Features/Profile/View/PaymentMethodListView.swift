//
//  PaymentMethodListView.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 07/01/26.
//
//  Payment account list view with sections for default and other payment methods.
//  Updated: Refactored to use iOS 18+ navigationDestination(isPresented:) API.
//

import SwiftUI
import SwiftData

struct PaymentMethodListView: View {
    let methods: [PaymentMethodEntity]
    let user: UserEntity

    @State private var showAddPaymentMethod = false
    @State private var navigateToEditDefault = false
    @State private var navigateToEditFirstOther = false
    
    // MARK: - Initializer
    init(methods: [PaymentMethodEntity], user: UserEntity) {
        self.methods = methods
        self.user = user
    }

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
        ScrollView {
            VStack(spacing: 0) {
                // MARK: - Payment Account Section (Default)
                if let defaultMethod = defaultMethod {
                    PaymentSectionHeader(title: "PAYMENT ACCOUNT") {
                        navigateToEditDefault = true
                    }

                    NavigationLink {
                        EditPaymentMethodView(method: defaultMethod)
                    } label: {
                        PaymentMethodRow(
                            providerName: defaultMethod.providerName,
                            destination: defaultMethod.destination,
                            holderName: defaultMethod.holderName,
                            isDefault: defaultMethod.isDefault
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                // MARK: - Another Account Section
                if !otherMethods.isEmpty {
                    PaymentSectionHeader(title: "ANOTHER ACCOUNT") {
                        navigateToEditFirstOther = true
                    }

                    ForEach(otherMethods) { method in
                        NavigationLink {
                            EditPaymentMethodView(method: method)
                        } label: {
                            PaymentMethodRow(
                                providerName: method.providerName,
                                destination: method.destination,
                                holderName: method.holderName,
                                isDefault: method.isDefault
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }

                // MARK: - Add Another Option Button
                AddPaymentMethodButton {
                    showAddPaymentMethod = true
                }
                .padding(.top, AppSpacing.md)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Payment Account")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showAddPaymentMethod) {
            AddPaymentMethodView(user: user)
        }
        .navigationDestination(isPresented: $navigateToEditDefault) {
            if let defaultMethod = defaultMethod {
                EditPaymentMethodView(method: defaultMethod)
            }
        }
        .navigationDestination(isPresented: $navigateToEditFirstOther) {
            if let firstOther = otherMethods.first {
                EditPaymentMethodView(method: firstOther)
            }
        }
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
                    Text("Failed to load SwiftData container")
                        .font(.caption)
                        .foregroundColor(.secondary)
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

            // Create mock payment methods
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

            // Insert into context on main actor
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
