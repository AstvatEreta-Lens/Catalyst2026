//
//  ProfileHeaderView.swift
//  Talangin
//
//  Created by Rifqi Rahman on 15/01/26.
//
//  Profile header component showing user photo, name, email, and account badge.
//  Edit functionality moved to navigation bar in ProfileView.
//

import SwiftUI

struct ProfileHeaderView: View {
    let profilePhotoData: Data?
    let fullName: String
    let email: String
    let accountBadge: String

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            // MARK: - Profile Photo
            Group {
                if let profilePhotoData,
                   let uiImage = UIImage(data: profilePhotoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .foregroundStyle(.gray)
                }
            }
            .frame(width: 80, height: 80)
            .clipShape(Circle())

            // MARK: - Name, Email, and Badge
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(fullName.isEmpty ? "John Doe" : fullName)
                    .font(.Headline)
                    .fontWeight(.semibold)

                Text(email.isEmpty ? "john.doe@gmail.com" : email)
                    .font(.Subheadline)
                    .foregroundColor(.secondary)
                
                Text(accountBadge)
                    .font(.Caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, AppSpacing.xs)
                    .padding(.vertical, AppSpacing.xxs)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(accountBadge == "Premium" ? AppColors.badgePremium : AppColors.accentWater)
                    )
            }

            Spacer()
        }
        .padding(.vertical, AppSpacing.md)
    }
}

#Preview {
    ProfileHeaderView(
        profilePhotoData: nil,
        fullName: "John Doe",
        email: "john.doe@gmail.com",
        accountBadge: "Free Account"
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
