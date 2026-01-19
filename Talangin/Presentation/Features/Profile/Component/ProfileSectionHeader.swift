//
//  ProfileSectionHeader.swift
//  Talangin
//
//  Created by Rifqi Rahman on 15/01/26.
//
//  Section header component for profile screen sections.
//

import SwiftUI

struct ProfileSectionHeader: View {
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
        .padding(.top, AppSpacing.md)
        .padding(.bottom, AppSpacing.xs)
    }
}

#Preview {
    ProfileSectionHeader(title: "PREFERENCES")
        .padding()
        .background(Color(.systemGroupedBackground))
}
