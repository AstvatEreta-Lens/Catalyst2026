//
//  GradientHeaderView.swift
//  Talangin
//
//  Created by Rifqi Rahman on 19/01/26.
//
//  Reusable gradient header component for detail views.
//  Displays profile photo with gradient background overlay.
//

import SwiftUI

struct GradientHeaderView: View {
    
    // MARK: - Properties
    let photoData: Data?
    let initials: String
    let name: String
    let subtitle: String
    
    // MARK: - Gradient Colors
    private let gradientColors: [Color] = [
        Color(red: 0.4, green: 0.5, blue: 0.9),   // Blue-purple
        Color(red: 0.2, green: 0.6, blue: 0.5)    // Teal-green
    ]
    
    // MARK: - Initializer
    init(
        photoData: Data? = nil,
        initials: String,
        name: String,
        subtitle: String
    ) {
        self.photoData = photoData
        self.initials = initials
        self.name = name
        self.subtitle = subtitle
    }
    
    var body: some View {
        ZStack {
            // MARK: - Gradient Background
            LinearGradient(
                colors: gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // MARK: - Content
            VStack(spacing: AppSpacing.sm) {
                // Profile Photo
                ContactAvatarView(
                    initials: initials,
                    photoData: photoData,
                    size: .large,
                    backgroundColor: .white.opacity(0.2),
                    foregroundColor: .white
                )
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 3)
                )
                
                // Name
                Text(name)
                    .font(.Title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // Subtitle (email)
                Text(subtitle)
                    .font(.Subheadline)
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(.vertical, AppSpacing.xl)
        }
        .frame(height: 220)
    }
}

// MARK: - Convenience Initializers

extension GradientHeaderView {
    
    /// Creates header from ContactEntity
    init(contact: ContactEntity) {
        self.photoData = contact.profilePhotoData
        self.initials = contact.initials
        self.name = contact.fullName
        self.subtitle = contact.email
    }
}

#Preview {
    VStack(spacing: 0) {
        GradientHeaderView(
            photoData: nil,
            initials: "SY",
            name: "Sari Yulia",
            subtitle: "saryulia@gmail.com"
        )
        
        Spacer()
    }
    .ignoresSafeArea(edges: .top)
}
