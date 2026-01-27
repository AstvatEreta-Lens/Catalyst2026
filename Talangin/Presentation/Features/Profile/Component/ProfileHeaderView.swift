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
            .frame(width: 64, height: 64)
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
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                HStack(spacing: AppSpacing.xs) {
                    Text(fullName.isEmpty ? "John Doe" : fullName)
                        .font(.Headline)
                        .fontWeight(.semibold)

                    Text(accountBadge)
                        .font(.Caption2)
                        .fontWeight(.medium)
                        .foregroundColor(accountBadge == "Premium" ? .white : Color(red: 0.20, green: 0.45, blue: 0.80))
                        .padding(.horizontal, AppSpacing.xs)
                        .padding(.vertical, AppSpacing.xxs)
                        .background(
                            Capsule()
                                .fill(accountBadge == "Premium" ? AppColors.badgePremium : Color(red: 0.85, green: 0.94, blue: 0.99))
                        )
                }

                Text(email.isEmpty ? "john.doe@gmail.com" : email)
                    .font(.Subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // MARK: - Edit Button
            Button {
                onEditTapped()
            } label: {
                Image(systemName: "pencil")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.top, 50)
        .frame(minHeight: 200)
        .background(Color(.systemBackground))
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
