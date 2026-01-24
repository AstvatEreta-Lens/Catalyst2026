//
//  AddPaymentMethodView.swift
//  Talangin
//
//  Created by Rifqi Rahman on 18/01/26.
//
//  Form view for adding a new payment method with input fields and default toggle.
//

import SwiftUI
import SwiftData

struct AddPaymentMethodView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - Form State
    @State private var providerName: String = ""
    @State private var destination: String = ""
    @State private var holderName: String = ""
    @State private var isDefault: Bool = false
    @State private var showSaveError = false
    @State private var saveErrorMessage: String?
    
    // User to associate with the payment method
    let user: UserEntity

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // MARK: - Form Fields
                    VStack(spacing: 0) {
                        // Bank/Wallet Name
                        TextField("Bank or Wallet Name", text: $providerName)
                            .font(.Body)
                            .padding(.horizontal, AppSpacing.lg)
                            .padding(.vertical, AppSpacing.md)
                            .background(Color(.systemBackground))

                        Divider()
                            .padding(.leading, AppSpacing.lg)

                        // Number
                        TextField("Account Number", text: $destination)
                            .font(.Body)
                            .keyboardType(.numberPad)
                            .padding(.horizontal, AppSpacing.lg)
                            .padding(.vertical, AppSpacing.md)
                            .background(Color(.systemBackground))

                        Divider()
                            .padding(.leading, AppSpacing.lg)

                        // Holder Name
                        TextField("Holder Name", text: $holderName)
                            .font(.Body)
                            .padding(.horizontal, AppSpacing.lg)
                            .padding(.vertical, AppSpacing.md)
                            .background(Color(.systemBackground))
                    }
                    .background(Color(.systemBackground))
                    .padding(.top, AppSpacing.md)

                    // MARK: - Set as Default Toggle
                    HStack {
                        Text("Set as default")
                            .font(.Body)
                            .foregroundColor(.primary)
                        Spacer()
                        Toggle("", isOn: $isDefault)
                            .tint(AppColors.toggleTint)
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.vertical, AppSpacing.md)
                    .background(Color(.systemBackground))
                    .padding(.top, AppSpacing.xs)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Add Payment Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        save()
                    }
                    .fontWeight(.semibold)
                    .disabled(providerName.isEmpty || destination.isEmpty)
                }
            }
            .alert("Error", isPresented: $showSaveError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(saveErrorMessage ?? "Failed to save payment method")
            }
        }
    }

    // MARK: - Actions
    private func save() {
        // If setting as default, unset other defaults first
        if isDefault {
            for method in user.paymentMethods ?? [] {
                method.isDefault = false
            }
        }
        
        // Create new payment method
        let newMethod = PaymentMethodEntity(
            providerName: providerName,
            destination: destination,
            holderName: holderName,
            isDefault: isDefault,
            user: user
        )
        
        modelContext.insert(newMethod)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            saveErrorMessage = error.localizedDescription
            showSaveError = true
        }
    }
}

//#Preview {
//    @MainActor
//    func makePreview() -> AnyView {
//        do {
//            let config = ModelConfiguration(isStoredInMemoryOnly: true)
//            let container = try ModelContainer(
//                for: Item.self, UserEntity.self, PaymentMethodEntity.self,
//                configurations: config
//            )
//
//            let mockUser = UserEntity(appleUserId: "preview")
//            let context = container.mainContext
//            context.insert(mockUser)
//
//            return AnyView(
//                AddPaymentMethodView(user: mockUser)
//                    .modelContainer(container)
//            )
//        } catch {
//            return AnyView(
//                VStack {
//                    Image(systemName: "exclamationmark.triangle")
//                        .font(.largeTitle)
//                        .foregroundColor(.orange)
//                    Text("Preview Error")
//                        .font(.headline)
//                    Text(error.localizedDescription)
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                        .multilineTextAlignment(.center)
//                        .padding()
//                }
//            )
//        }
//    }
//
//    return makePreview()
//}
