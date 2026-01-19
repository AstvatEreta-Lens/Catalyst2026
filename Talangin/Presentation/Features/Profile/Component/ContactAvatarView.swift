//
//  ContactAvatarView.swift
//  Talangin
//
//  Created by Rifqi Rahman on 19/01/26.
//
//  Reusable avatar component for contacts showing either profile photo or initials.
//  Supports different sizes and can be used in lists, headers, and detail views.
//

import SwiftUI

struct ContactAvatarView: View {
    
    // MARK: - Size Enum
    enum Size {
        case small      // 40pt - for list rows
        case medium     // 64pt - for headers
        case large      // 100pt - for detail views
        
        var dimension: CGFloat {
            switch self {
            case .small: return 40
            case .medium: return 64
            case .large: return 100
            }
        }
        
        var fontSize: CGFloat {
            switch self {
            case .small: return 14
            case .medium: return 22
            case .large: return 36
            }
        }
    }
    
    // MARK: - Properties
    let initials: String
    let photoData: Data?
    let size: Size
    var backgroundColor: Color
    var foregroundColor: Color
    
    // MARK: - Initializer
    init(
        initials: String,
        photoData: Data? = nil,
        size: Size = .small,
        backgroundColor: Color = .blue.opacity(0.15),
        foregroundColor: Color = .blue
    ) {
        self.initials = initials
        self.photoData = photoData
        self.size = size
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
    }
    
    var body: some View {
        Group {
            if let photoData, let uiImage = UIImage(data: photoData) {
                // MARK: - Photo Avatar
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                // MARK: - Initials Avatar
                Text(initials)
                    .font(.system(size: size.fontSize, weight: .semibold))
                    .foregroundColor(foregroundColor)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(backgroundColor)
            }
        }
        .frame(width: size.dimension, height: size.dimension)
        .clipShape(Circle())
    }
}

// MARK: - Convenience Initializers

extension ContactAvatarView {
    
    /// Creates avatar from ContactEntity
    /// BACKEND NOTE: Update this when ContactEntity is fully integrated
    init(contact: ContactEntity, size: Size = .small) {
        self.initials = contact.initials
        self.photoData = contact.profilePhotoData
        self.size = size
        self.backgroundColor = .blue.opacity(0.15)
        self.foregroundColor = .blue
    }
    
    /// Creates avatar with just a name (computes initials automatically)
    init(name: String, photoData: Data? = nil, size: Size = .small) {
        let components = name.split(separator: " ")
        let initials = components.prefix(2).compactMap { $0.first }
        self.initials = String(initials).uppercased()
        self.photoData = photoData
        self.size = size
        self.backgroundColor = .blue.opacity(0.15)
        self.foregroundColor = .blue
    }
}

#Preview("All Sizes") {
    VStack(spacing: AppSpacing.lg) {
        HStack(spacing: AppSpacing.lg) {
            ContactAvatarView(initials: "AS", size: .small)
            ContactAvatarView(initials: "JD", size: .medium)
            ContactAvatarView(initials: "SY", size: .large)
        }
        
        Text("With different colors")
            .font(.Caption)
            .foregroundColor(.secondary)
        
        HStack(spacing: AppSpacing.lg) {
            ContactAvatarView(
                initials: "AB",
                size: .small,
                backgroundColor: .green.opacity(0.15),
                foregroundColor: .green
            )
            ContactAvatarView(
                initials: "CD",
                size: .small,
                backgroundColor: .orange.opacity(0.15),
                foregroundColor: .orange
            )
            ContactAvatarView(
                initials: "EF",
                size: .small,
                backgroundColor: .purple.opacity(0.15),
                foregroundColor: .purple
            )
        }
    }
    .padding()
}
