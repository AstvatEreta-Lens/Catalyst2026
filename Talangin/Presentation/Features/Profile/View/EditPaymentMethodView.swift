//
//  EditPaymentMethodView.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 07/01/26.
//
//  Form view for editing a payment method with input fields and default toggle.
//  Updated: Changed title to "Edit Payment Account" and added logic to unset other defaults.
//

import SwiftUI
import SwiftData

struct EditPaymentMethodView: View {
    @Bindable var method: PaymentMethodEntity
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var showSaveError = false
    @State private var saveErrorMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // MARK: - Form Fields
                    VStack(spacing: 0) {
                        // Bank/Wallet Name
                        TextField("Bank or Wallet Name", text: Binding(
                            get: { method.providerName ?? "" },
                            set: { method.providerName = $0 }
                        ))
                            .font(.Body)
                            .padding(.horizontal, AppSpacing.lg)
                            .padding(.vertical, AppSpacing.md)
                            .background(Color(.systemBackground))

                        Divider()
                            .padding(.leading, AppSpacing.lg)

                        // Number
                        TextField("Account Number", text: Binding(
                            get: { method.destination ?? "" },
                            set: { method.destination = $0 }
                        ))
                            .font(.Body)
                            .keyboardType(.numberPad)
                            .padding(.horizontal, AppSpacing.lg)
                            .padding(.vertical, AppSpacing.md)
                            .background(Color(.systemBackground))

                        Divider()
                            .padding(.leading, AppSpacing.lg)

                        // Holder Name
                        TextField("Holder Name", text: Binding(
                            get: { method.holderName ?? "" },
                            set: { method.holderName = $0 }
                        ))
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
                        Toggle("", isOn: Binding(
                            get: { method.isDefault ?? false },
                            set: { newValue in
                                method.isDefault = newValue
                                // If setting as default, unset other defaults
                                if newValue, let user = method.user {
                                    for otherMethod in user.paymentMethods ?? [] where otherMethod.id != method.id {
                                        otherMethod.isDefault = false
                                    }
                                }
                            }
                        ))
                        .tint(AppColors.toggleTint)
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.vertical, AppSpacing.md)
                    .background(Color(.systemBackground))
                    .padding(.top, AppSpacing.xs)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Edit Payment Account")
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
                    .disabled((method.providerName ?? "").isEmpty || (method.destination ?? "").isEmpty)
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
        do {
            // Ensure only one default exists
            if method.isDefault == true, let user = method.user {
                for otherMethod in user.paymentMethods ?? [] where otherMethod.id != method.id {
                    otherMethod.isDefault = false
                }
            }
            
            try modelContext.save()
            dismiss()
        } catch {
            saveErrorMessage = error.localizedDescription
            showSaveError = true
        }
    }
}
//
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
//            let mockMethod = PaymentMethodEntity(
//                providerName: "BCA",
//                destination: "120-12038-19333",
//                holderName: "Rifqi Smith",
//                isDefault: true,
//                user: mockUser
//            )
//
//            // Insert into context on the main actor
//            let context = container.mainContext
//            context.insert(mockUser)
//            context.insert(mockMethod)
//
//            return AnyView(
//                EditPaymentMethodView(method: mockMethod)
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
