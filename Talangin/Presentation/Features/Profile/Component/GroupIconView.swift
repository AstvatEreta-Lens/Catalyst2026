//
//  GroupIconView.swift
//  Talangin
//
//  Created by Rifqi Rahman on 19/01/26.
//
//  Reusable group icon component showing either custom photo or SF Symbol icon.
//  Displays group icon with customizable background color and size.
//

import SwiftUI

struct GroupIconView: View {
    
    // MARK: - Size Enum
    enum Size {
        case small      // 40pt - for list rows
        case medium     // 56pt - for detail headers
        case large      // 80pt - for full detail views
        
        var dimension: CGFloat {
            switch self {
            case .small: return 40
            case .medium: return 56
            case .large: return 80
            }
        }
        
        var iconSize: CGFloat {
            switch self {
            case .small: return 20
            case .medium: return 28
            case .large: return 40
            }
        }
        
        var cornerRadius: CGFloat {
            switch self {
            case .small: return 10
            case .medium: return 14
            case .large: return 20
            }
        }
    }
    
    // MARK: - Properties
    let iconName: String
    let photoData: Data?
    let backgroundColor: Color
    let size: Size
    
    // MARK: - Initializer
    init(
        iconName: String = "person.3.fill",
        photoData: Data? = nil,
        backgroundColor: Color = Color.gray.opacity(0.15),
        size: Size = .small
    ) {
        self.iconName = iconName
        self.photoData = photoData
        self.backgroundColor = backgroundColor
        self.size = size
    }
    
    var body: some View {
        Group {
            if let photoData, let uiImage = UIImage(data: photoData) {
                // MARK: - Custom Photo
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                // MARK: - SF Symbol Icon
                Image(systemName: iconName)
                    .font(.system(size: size.iconSize))
                    .foregroundColor(.primary.opacity(0.7))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(backgroundColor)
            }
        }
        .frame(width: size.dimension, height: size.dimension)
        .clipShape(RoundedRectangle(cornerRadius: size.cornerRadius))
    }
}

// MARK: - Convenience Initializers

extension GroupIconView {
    
    /// Creates icon from GroupEntity
    /// BACKEND NOTE: Update this when GroupEntity is fully integrated
    init(group: GroupEntity, size: Size = .small) {
        self.iconName = group.iconName ?? "person.fill"
        self.photoData = group.groupPhotoData
        self.backgroundColor = group.iconBackgroundColor
        self.size = size
    }
}

#Preview("All Sizes") {
    VStack(spacing: AppSpacing.lg) {
        Text("Different Sizes")
            .font(.Caption)
            .foregroundColor(.secondary)
        
        HStack(spacing: AppSpacing.lg) {
            GroupIconView(
                iconName: "hand.raised.fingers.spread.fill",
                backgroundColor: Color(hex: "#FFF3E0") ?? .orange.opacity(0.15),
                size: .small
            )
            GroupIconView(
                iconName: "mountain.2.fill",
                backgroundColor: Color(hex: "#E8F5E9") ?? .green.opacity(0.15),
                size: .medium
            )
            GroupIconView(
                iconName: "car.fill",
                backgroundColor: Color(hex: "#FCE4EC") ?? .pink.opacity(0.15),
                size: .large
            )
        }
        
        Text("Various Icons")
            .font(.Caption)
            .foregroundColor(.secondary)
        
        HStack(spacing: AppSpacing.md) {
            GroupIconView(
                iconName: "figure.2.and.child.holdinghands",
                backgroundColor: Color(hex: "#E3F2FD") ?? .blue.opacity(0.15),
                size: .small
            )
            GroupIconView(
                iconName: "airplane",
                backgroundColor: Color(hex: "#F3E5F5") ?? .purple.opacity(0.15),
                size: .small
            )
            GroupIconView(
                iconName: "fork.knife",
                backgroundColor: Color(hex: "#FFEBEE") ?? .red.opacity(0.15),
                size: .small
            )
            GroupIconView(
                iconName: "building.2.fill",
                backgroundColor: Color(hex: "#E0F2F1") ?? .teal.opacity(0.15),
                size: .small
            )
        }
    }
    .padding()
}
