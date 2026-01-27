//
//  SplashView.swift
//  Talangin
//
//  Created by Rifqi Rahman on 19/01/26.
//
//  Splash/Welcome screen shown when app launches.
//  Features gradient background, app branding, and call-to-action button.
//
//  BACKEND DEVELOPER NOTES:
//  -------------------------
//  This is a purely UI component with no backend dependencies.
//  After user taps "Start Expense", they proceed to authentication.
//  No API calls needed here.
//

import SwiftUI

struct SplashView: View {
    
    // MARK: - Properties
    
    /// Action triggered when user taps "Start Expense" button
    let onContinue: () -> Void
    
    var body: some View {
        ZStack {
            // MARK: - Gradient Background
            gradientBackground
            
            // MARK: - Content
            VStack {
                Spacer()
                
                // App Branding
                brandingSection
                
                // Call to Action Button
                startButton
                    .padding(.bottom, AppSpacing.xxxl)
            }
            .padding(.horizontal, AppSpacing.xl)
        }
        .ignoresSafeArea()
    }
    
    
    // MARK: - Branding Section
    private var brandingSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            // App Logo and Name
            HStack(spacing: AppSpacing.sm) {
                // Logo Placeholder
               Image("AppIconImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
    
                
                Text("Talangin")
                    .font(.Title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            
            // Tagline
            Text("A simple way to split expenses and stay fair with friends")
                .font(.appLargeTitle)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, AppSpacing.xl)
    }
    
    // MARK: - Start Button
    private var startButton: some View {
        Button {
            onContinue()
        } label: {
            Text("Start Expense")
                .font(.Headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.md)
                .background(
                    RoundedCorner(radius: 14)
                        .fill(AppColors.accentWater)
                )
        }
    }
}

#Preview {
    SplashView {
        print("Continue tapped")
    }
}
