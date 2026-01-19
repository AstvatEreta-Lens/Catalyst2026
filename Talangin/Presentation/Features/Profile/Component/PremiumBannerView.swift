//
//  PremiumBannerView.swift
//  Talangin
//
//  Created by Rifqi Rahman on 15/01/26.
//
//  Premium features banner component with gradient background and upgrade button.
//

import SwiftUI

struct PremiumBannerView: View {
    let onUpgradeTapped: () -> Void
    
    // MARK: - Colors
    private let gradientStart = Color(red: 0.78, green: 0.89, blue: 0.94) // Light blue
    private let gradientEnd = Color(red: 0.82, green: 0.93, blue: 0.88)   // Mint green
    private let titleColor = Color(red: 0.12, green: 0.24, blue: 0.42)    // Dark blue
    private let buttonTextColor = Color(red: 0.20, green: 0.45, blue: 0.80) // Button blue

    var body: some View {
        ZStack(alignment: .leading) {
            // MARK: - Background with gradient
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [gradientStart, gradientEnd],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            HStack(spacing: 0) {
                // MARK: - Text Content
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    Text("Enjoy Our Premium\nFeatures")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(titleColor)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)

                    Button {
                        onUpgradeTapped()
                    } label: {
                        Text("Upgrade Now")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(buttonTextColor)
                            .padding(.horizontal, AppSpacing.lg)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                            )
                    }
                }
                .padding(.leading, AppSpacing.lg)
                .frame(maxWidth: .infinity, alignment: .leading)

                // MARK: - Premium Image
                Image("premiumImage")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 160, height: 150)
                    .clipped()
                    .clipShape(
                        RoundedCorner(radius: 16, corners: [.topRight, .bottomRight])
                    )
            }
        }
        .frame(height: 150)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.md)
    }
}

// MARK: - Custom RoundedCorner Shape
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    PremiumBannerView(onUpgradeTapped: {
        print("Upgrade tapped (preview)")
    })
}
