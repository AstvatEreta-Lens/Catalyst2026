//
//  ProfileHeaderView.swift
//  Talangin
//
//  Created by Rifqi Rahman on 15/01/26.
//
//  Profile header component showing user photo, name, email, account badge, and edit button.
//

import SwiftUI
import PhotosUI

struct ProfileHeaderView: View {
    let profilePhotoData: Data?
    let fullName: String
    let email: String
    let accountBadge: String
    let onEditTapped: () -> Void
    let onPhotoChanged: (Data) -> Void

    @State private var selectedItem: PhotosPickerItem?

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
            .overlay(
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images
                ) {
                    EmptyView()
                }
                .opacity(0)
                .frame(width: 64, height: 64)
            )
            .onChange(of: selectedItem) {
                Task {
                    if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                        onPhotoChanged(data)
                    }
                }
            }

            // MARK: - Name and Email
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                HStack(spacing: AppSpacing.xs) {
                    Text(fullName.isEmpty ? "John Doe" : fullName)
                        .font(.Headline)
                        .fontWeight(.semibold)

                }

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
//                        Capsule()
//                            .fill(accountBadge == "Premium" ? AppColors.badgePremium : AppColors.accentWater)
                    )
            }

            Spacer()

            // MARK: - Edit Button
            VStack(alignment: .trailing){
                Button {
                    onEditTapped()
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(.secondary)
                }
                

            }
        }
        .padding(.horizontal, AppSpacing.xxxs)
        .padding(.vertical, AppSpacing.lg)
        .background(Color(.systemBackground))
        .frame(height: 100)
    }
    
}

#Preview {
    ProfileHeaderView(
        profilePhotoData: nil,
        fullName: "John Doe",
        email: "john.doe@gmail.com",
        accountBadge: "Free Account",
        onEditTapped: {
            print("Edit tapped")
        },
        onPhotoChanged: { data in
            print("Photo changed")
        }
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}

