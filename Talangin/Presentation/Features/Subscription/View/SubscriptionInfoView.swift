//
//  SubscriptionInfoView.swift
//  Talangin
//
//  Created by Rifqi Rahman on 19/01/26.
//
//  Subscription info view showing current plan, features, and management actions.
//  Displays subscription details for premium users.
//
//  BACKEND DEVELOPER NOTES:
//  -------------------------
//  This view displays the user's current subscription status.
//  
//  StoreKit Integration:
//  1. Fetch subscription status from StoreKit/server
//  2. Display actual subscription expiration date
//  3. Handle subscription management (Apple's subscription management)
//  4. Implement restore purchases with proper validation
//  5. Handle promo code redemption
//
//  Suggested implementation:
//  - Use Transaction.currentEntitlements for active subscriptions
//  - Open App Store subscription management via URL scheme
//  - Validate receipts server-side for security
//

import SwiftUI

struct SubscriptionInfoView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var isRestoring = false
    @State private var showPromoCodeSheet = false
    @State private var showRestoreSuccess = false
    @State private var showRestoreError = false
    
    // MARK: - Mock Data (Replace with actual subscription data)
    private let currentPlan = "Premium"
    private let planType = "Monthly Subscription"
    private let isActive = true
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // MARK: - Current Plan Section
                currentPlanSection
                
                // MARK: - Plan Features Section
                planFeaturesSection
                
                // MARK: - Actions Section
                actionsSection
                
                // MARK: - Manage Button
                manageButton
            }
            .padding(.bottom, AppSpacing.xxxl)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Subscription")
        .navigationBarTitleDisplayMode(.large)
        .alert("Restored Successfully", isPresented: $showRestoreSuccess) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your purchases have been restored successfully.")
        }
        .alert("Restore Failed", isPresented: $showRestoreError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Unable to restore purchases. Please try again later.")
        }
        .sheet(isPresented: $showPromoCodeSheet) {
            PromoCodeSheet()
        }
    }
    
    // MARK: - Current Plan Section
    private var currentPlanSection: some View {
        VStack(spacing: 0) {
            // Section Header
            SectionHeader(title: "CURRENT PLAN")
            
            // Plan Card
            HStack(spacing: AppSpacing.md) {
                // Plan Icon
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [AppColors.primary, AppColors.primary.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "crown.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    )
                
                // Plan Info
                VStack(alignment: .leading, spacing: 2) {
                    Text(currentPlan)
                        .font(.Headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(planType)
                        .font(.Subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Status Badge
                if isActive {
                    Text("Active")
                        .font(.Caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .padding(.horizontal, AppSpacing.sm)
                        .padding(.vertical, AppSpacing.xxs)
                        .background(
                            Capsule()
                                .stroke(Color.primary.opacity(0.3), lineWidth: 1)
                        )
                }
            }
            .padding(AppSpacing.md)
            .background(Color(.systemBackground))
        }
    }
    
    // MARK: - Plan Features Section
    private var planFeaturesSection: some View {
        VStack(spacing: 0) {
            // Section Header
            SectionHeader(title: "PLAN FEATURES")
            
            // Features List
            VStack(spacing: 0) {
                ForEach(Array(SubscriptionFeature.allFeatures.enumerated()), id: \.element.title) { index, feature in
                    SubscriptionFeatureRow(feature: feature)
                    
                    if index < SubscriptionFeature.allFeatures.count - 1 {
                        Divider()
                            .padding(.leading, AppSpacing.lg + 28)
                    }
                }
            }
            .background(Color(.systemBackground))
        }
    }
    
    // MARK: - Actions Section
    private var actionsSection: some View {
        VStack(spacing: 0) {
            // Section Header
            SectionHeader(title: "ACTIONS")
            
            VStack(spacing: 0) {
                // Restore Purchases
                Button {
                    handleRestorePurchases()
                } label: {
                    HStack(spacing: AppSpacing.md) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 18))
                            .foregroundColor(AppColors.primary)
                            .frame(width: 28)
                        
                        Text("Restore Purchases")
                            .font(.Body)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if isRestoring {
                            ProgressView()
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.vertical, AppSpacing.md)
                }
                .disabled(isRestoring)
                
                Divider()
                    .padding(.leading, AppSpacing.lg + 28)
                
                // Promo Code
                Button {
                    showPromoCodeSheet = true
                } label: {
                    HStack(spacing: AppSpacing.md) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 18))
                            .foregroundColor(AppColors.primary)
                            .frame(width: 28)
                        
                        Text("Have a promo code?")
                            .font(.Body)
                            .foregroundColor(AppColors.primary)
                        
                        Spacer()
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.vertical, AppSpacing.md)
                }
            }
            .background(Color(.systemBackground))
        }
    }
    
    // MARK: - Manage Button
    private var manageButton: some View {
        Button {
            handleManageSubscription()
        } label: {
            Text("Manage Subscription")
                .font(.Headline)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppColors.primary, lineWidth: 1.5)
                )
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.top, AppSpacing.xl)
    }
    
    // MARK: - Actions
    
    private func handleRestorePurchases() {
        isRestoring = true
        
        // BACKEND NOTE: Implement StoreKit restore purchases
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isRestoring = false
            showRestoreSuccess = true
        }
    }
    
    private func handleManageSubscription() {
        // BACKEND NOTE: Open App Store subscription management
        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Section Header

private struct SectionHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.Caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.top, AppSpacing.lg)
        .padding(.bottom, AppSpacing.xs)
    }
}

// MARK: - Subscription Feature

struct SubscriptionFeature {
    let icon: String
    let title: String
    let subtitle: String
    
    static let allFeatures: [SubscriptionFeature] = [
        SubscriptionFeature(
            icon: "star.fill",
            title: "No Ads",
            subtitle: "Talangin with no distraction"
        ),
        SubscriptionFeature(
            icon: "star.fill",
            title: "Unlimited Expenses",
            subtitle: "Add infinite shared-expense"
        ),
        SubscriptionFeature(
            icon: "star.fill",
            title: "OCR Scanning",
            subtitle: "Scan receipts automatically"
        ),
        SubscriptionFeature(
            icon: "star.fill",
            title: "Premium Badge",
            subtitle: "Show your supporter status"
        )
    ]
}

// MARK: - Subscription Feature Row

private struct SubscriptionFeatureRow: View {
    let feature: SubscriptionFeature
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: feature.icon)
                .font(.system(size: 18))
                .foregroundColor(AppColors.primary)
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(feature.title)
                    .font(.Body)
                    .foregroundColor(.primary)
                
                Text(feature.subtitle)
                    .font(.Subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.md)
    }
}

// MARK: - Promo Code Sheet

private struct PromoCodeSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var promoCode: String = ""
    @State private var isRedeeming = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.lg) {
                // Icon
                Image(systemName: "ticket.fill")
                    .font(.system(size: 50))
                    .foregroundColor(AppColors.primary)
                    .padding(.top, AppSpacing.xl)
                
                // Title
                Text("Enter Promo Code")
                    .font(.Title2)
                    .fontWeight(.bold)
                
                // Description
                Text("If you have a promo code, enter it below to redeem your offer.")
                    .font(.Body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.lg)
                
                // Text Field
                TextField("Promo Code", text: $promoCode)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.top, AppSpacing.md)
                
                // Redeem Button
                Button {
                    isRedeeming = true
                    // BACKEND NOTE: Implement promo code redemption
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        isRedeeming = false
                        dismiss()
                    }
                } label: {
                    HStack {
                        if isRedeeming {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Redeem")
                                .fontWeight(.semibold)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.md)
                    .background(promoCode.isEmpty ? AppColors.gray02 : AppColors.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(promoCode.isEmpty || isRedeeming)
                .padding(.horizontal, AppSpacing.lg)
                
                Spacer()
            }
            .navigationTitle("Promo Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    NavigationStack {
        SubscriptionInfoView()
    }
}
