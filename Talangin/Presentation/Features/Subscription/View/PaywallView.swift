//
//  PaywallView.swift
//  Talangin
//
//  Created by Rifqi Rahman on 19/01/26.
//
//  Paywall view for premium subscription with gradient header, features list, and pricing options.
//  Enhanced with animations and visual appeal.
//
//  BACKEND DEVELOPER NOTES:
//  -------------------------
//  This view displays the premium subscription paywall.
//  
//  StoreKit Integration:
//  1. Replace mock prices with actual product prices from StoreKit
//  2. Implement purchase flow using StoreKit 2
//  3. Handle subscription status verification
//  4. Implement restore purchases functionality
//
//  Suggested implementation:
//  - Use @Environment(\.purchase) for StoreKit 2
//  - Store subscription status in UserDefaults/Keychain
//  - Sync with server for subscription validation
//
import SwiftUI

struct PaywallView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: SubscriptionPlan = .monthly
    @State private var isLoading = false
    @State private var showSubscriptionInfo = false
    
    // MARK: - Gradient Colors (Using brand colors from ColorTokens)
    private let gradientColors: [Color] = [
        ColorTokens.systemOlive02Light,   // Olive/Green
        ColorTokens.systemWater02Light,   // Water/Teal
        ColorTokens.systemBlueLight       // Blue
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // MARK: - Gradient Header
                    gradientHeader
                    
                    // MARK: - Content
                    VStack(spacing: AppSpacing.lg) {
                        // Title Section
                        titleSection
                        
                        // Features Section
                        featuresSection
                        
                        // Pricing Section
                        pricingSection
                        
                        // Subscribe Button
                        subscribeButton
                        
                        // Terms
                        termsText
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.top, AppSpacing.xl)
                    .padding(.bottom, AppSpacing.xxxl)
                }
            }
            .background(Color(.systemGroupedBackground))
            .ignoresSafeArea(edges: .top)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationDestination(isPresented: $showSubscriptionInfo) {
                SubscriptionInfoView()
            }
        }
    }
    
    // MARK: - Gradient Header
    private var gradientHeader: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                colors: gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Decorative Elements
            GeometryReader { geometry in
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 200, height: 200)
                    .offset(x: geometry.size.width - 100, y: -50)
                
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 150, height: 150)
                    .offset(x: -50, y: 100)
                
                Circle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 100, height: 100)
                    .offset(x: geometry.size.width - 50, y: 150)
            }
            
            // Crown Icon
            VStack {
                Image(systemName: "crown.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
            }
        }
        .frame(height: 220)
    }
    
    // MARK: - Title Section
    private var titleSection: some View {
        VStack(spacing: AppSpacing.sm) {
            Text("Jadi Penalang yang Hebat")
                .font(.Title1)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            Text("Get the best of Talangin")
                .font(.Body)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Features Section
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Premium features")
                .font(.Headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .padding(.bottom, AppSpacing.xs)
            
            VStack(spacing: 0) {
                ForEach(PremiumFeature.allFeatures, id: \.title) { feature in
                    FeatureRow(feature: feature)
                }
            }
            .padding(AppSpacing.md)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    // MARK: - Pricing Section
    private var pricingSection: some View {
        HStack(spacing: AppSpacing.md) {
            // Monthly Plan
            PricingCard(
                plan: .monthly,
                isSelected: selectedPlan == .monthly,
                onSelect: { selectedPlan = .monthly }
            )
            
            // Annually Plan
            PricingCard(
                plan: .annually,
                isSelected: selectedPlan == .annually,
                onSelect: { selectedPlan = .annually }
            )
        }
    }
    
    // MARK: - Subscribe Button
    private var subscribeButton: some View {
        Button {
            handleSubscribe()
        } label: {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Subscribe Now")
                        .font(.Headline)
                        .fontWeight(.semibold)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.md)
            .background(AppColors.primary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: AppColors.primary.opacity(0.3), radius: 8, y: 4)
        }
        .disabled(isLoading)
        .padding(.top, AppSpacing.sm)
    }
    
    // MARK: - Terms Text
    private var termsText: some View {
        VStack(spacing: AppSpacing.xs) {
            Text("By subscribing, you agree to our")
                .font(.Caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 4) {
                Button("Terms of Service") {
                    // BACKEND NOTE: Open terms URL
                }
                .font(.Caption)
                .foregroundColor(AppColors.primary)
                
                Text("and")
                    .font(.Caption)
                    .foregroundColor(.secondary)
                
                Button("Privacy Policy") {
                    // BACKEND NOTE: Open privacy URL
                }
                .font(.Caption)
                .foregroundColor(AppColors.primary)
            }
        }
        .multilineTextAlignment(.center)
    }
    
    // MARK: - Actions
    private func handleSubscribe() {
        isLoading = true
        
        // BACKEND NOTE: Implement StoreKit 2 purchase flow here
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            // Navigate to subscription info on success
            showSubscriptionInfo = true
        }
    }
}

// MARK: - Subscription Plan Enum

enum SubscriptionPlan {
    case monthly
    case annually
    
    var title: String {
        switch self {
        case .monthly: return "Monthly"
        case .annually: return "Annually"
        }
    }
    
    var price: String {
        switch self {
        case .monthly: return "$2.99"
        case .annually: return "$19.99"
        }
    }
    
    var period: String {
        switch self {
        case .monthly: return "/month"
        case .annually: return "/year"
        }
    }
    
    var savings: String? {
        switch self {
        case .monthly: return nil
        case .annually: return "Save 44%"
        }
    }
}

// MARK: - Premium Feature

struct PremiumFeature {
    let icon: String
    let title: String
    
    static let allFeatures: [PremiumFeature] = [
        PremiumFeature(icon: "checkmark", title: "No Ads"),
        PremiumFeature(icon: "checkmark", title: "Unlimited expenses"),
        PremiumFeature(icon: "checkmark", title: "OCR Receipt Scanning"),
        PremiumFeature(icon: "checkmark", title: "Unlimited App Clip use"),
        PremiumFeature(icon: "checkmark", title: "Reminder customization"),
        PremiumFeature(icon: "checkmark", title: "Premium Badge"),
        PremiumFeature(icon: "checkmark", title: "Support Development")
    ]
}

// MARK: - Feature Row

private struct FeatureRow: View {
    let feature: PremiumFeature
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: feature.icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColors.primary)
                .frame(width: 20)
            
            Text(feature.title)
                .font(.Body)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.vertical, AppSpacing.sm)
    }
}

// MARK: - Pricing Card

private struct PricingCard: View {
    let plan: SubscriptionPlan
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button {
            onSelect()
        } label: {
            VStack(spacing: AppSpacing.sm) {
                // Savings Badge (for annually)
                if let savings = plan.savings {
                    Text(savings)
                        .font(.Caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, AppSpacing.sm)
                        .padding(.vertical, AppSpacing.xxs)
                        .background(
                            Capsule()
                                .fill(AppColors.warning)
                        )
                } else {
                    // Placeholder for alignment
                    Text(" ")
                        .font(.Caption2)
                        .padding(.vertical, AppSpacing.xxs)
                }
                
                // Plan Title
                Text(plan.title)
                    .font(.Subheadline)
                    .foregroundColor(.secondary)
                
                // Price
                Text(plan.price)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                
                // Period
                Text(plan.period)
                    .font(.Caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.lg)
            .padding(.horizontal, AppSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? AppColors.primary : Color.clear, lineWidth: 2)
                    )
                    .shadow(
                        color: isSelected ? AppColors.primary.opacity(0.2) : Color.black.opacity(0.05),
                        radius: isSelected ? 8 : 4,
                        y: 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

#Preview {
    PaywallView()
}
