//
//  OnboardingPaymentView.swift
//  Talangin
//
//  Created by Rifqi Rahman on 19/01/26.
//
//  Second step of user onboarding: collecting payment account information.
//  This is where friends will send money when settling expenses.
//
//  BACKEND DEVELOPER NOTES:
//  -------------------------
//  Payment Method Setup:
//  1. This view collects the user's primary payment method
//  2. Bank/wallet name (e.g., BCA, GoPay, OVO, DANA)
//  3. Account number for transfers
//  4. Account holder name for verification
//
//  API Integration:
//  - POST /users/payment-methods { providerName, accountNumber, holderName }
//  - This becomes the user's default payment method
//  - Should be encrypted at rest in the database
//
//  SwiftData Integration:
//  - Create PaymentMethodEntity with isDefault = true
//  - Associate with current UserEntity
//  - Save context after creation
//
//  Security Considerations:
//  - Consider masking account numbers in UI after entry
//  - Validate account number format based on provider
//  - Never log full account numbers
//

import SwiftUI

struct OnboardingPaymentView: View {
    
    // MARK: - Properties
    @State private var bankName: String = ""
    @State private var accountNumber: String = ""
    @State private var holderName: String = ""
    
    /// Callback when user completes onboarding
    let onComplete: (String, String, String) -> Void
    
    /// Callback when user skips this step
    let onSkip: () -> Void
    
    // MARK: - Computed Properties
    private var isFormValid: Bool {
        !bankName.isEmpty && !accountNumber.isEmpty && !holderName.isEmpty
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // MARK: - Background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            // MARK: - Gradient Header
            gradientHeader
            
            // MARK: - Content
            ScrollView {
                VStack(spacing: 0) {
                    // Spacer for gradient area
                    Color.clear
                        .frame(height: 200)
                    
                    // Card Content
                    cardContent
                }
            }
        }
    }
    
    // MARK: - Gradient Header
    private var gradientHeader: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color("#2a6a5a"),
                    Color("#3a8a7a"),
                    Color("#4aaa9a")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Decorative Element
            VStack {
                Spacer()
                Image(systemName: "creditcard.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.bottom, AppSpacing.xxxl)
            }
        }
        .frame(height: 280)
        .ignoresSafeArea(edges: .top)
    }
    
    // MARK: - Card Content
    private var cardContent: some View {
        VStack(spacing: AppSpacing.xl) {
            // MARK: - Header
            headerSection
            
            // MARK: - Form Fields
            formSection
            
            Spacer(minLength: AppSpacing.xl)
            
            // MARK: - Buttons
            buttonSection
        }
        .padding(.horizontal, AppSpacing.xl)
        .padding(.top, AppSpacing.xl)
        .padding(.bottom, AppSpacing.xxxl)
        .background(
            RoundedCorner(radius: 24, corners: [.topLeft, .topRight])
                .fill(Color(.systemBackground))
        )
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Where should friends pay you?")
                .font(.Title1)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("Add your payment account so friends know where to transfer money when settling expenses")
                .font(.Body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Form Section
    private var formSection: some View {
        VStack(spacing: AppSpacing.md) {
            // Bank/Wallet Name
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("Bank or E-Wallet")
                    .font(.Subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                OnboardingTextField(
                    placeholder: "e.g., BCA, GoPay, OVO",
                    text: $bankName,
                    showClearButton: true
                )
            }
            
            // Account Number
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("Account Number")
                    .font(.Subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                OnboardingTextField(
                    placeholder: "e.g., 1234567890",
                    text: $accountNumber,
                    keyboardType: .numberPad,
                    showClearButton: true
                )
            }
            
            // Holder Name
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("Account Holder Name")
                    .font(.Subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                OnboardingTextField(
                    placeholder: "Name as shown on account",
                    text: $holderName,
                    showClearButton: true
                )
            }
            
            // Info Note
            infoNote
        }
    }
    
    // MARK: - Info Note
    private var infoNote: some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 16))
                .foregroundColor(AppColors.info)
            
            Text("You can add more payment methods later in your profile settings")
                .font(.Caption)
                .foregroundColor(.secondary)
        }
        .padding(AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(AppColors.info.opacity(0.1))
        )
    }
    
    // MARK: - Button Section
    private var buttonSection: some View {
        VStack(spacing: AppSpacing.md) {
            // Complete Button
            Button {
                onComplete(
                    bankName.trimmingCharacters(in: .whitespaces),
                    accountNumber.trimmingCharacters(in: .whitespaces),
                    holderName.trimmingCharacters(in: .whitespaces)
                )
            } label: {
                Text("Complete Setup")
                    .font(.Headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isFormValid ? AppColors.primary : AppColors.gray02)
                    )
            }
            .disabled(!isFormValid)
            
            // Skip Button
            Button {
                onSkip()
            } label: {
                Text("Skip for now")
                    .font(.Subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    OnboardingPaymentView(
        onComplete: { bank, number, holder in
            print("Bank: \(bank), Number: \(number), Holder: \(holder)")
        },
        onSkip: {
            print("Skipped")
        }
    )
}
