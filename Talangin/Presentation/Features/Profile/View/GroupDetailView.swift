//
//  GroupDetailView.swift
//  Talangin
//
//  Created by Rifqi Rahman on 19/01/26.
//
//  Group detail view showing group info, members, and navigation to expenses.
//  Placeholder view for group management functionality.
//
//  BACKEND DEVELOPER NOTES:
//  -------------------------
//  This view displays group details. To integrate with backend:
//  1. Fetch group details including member list from API
//  2. Load group expenses summary
//  3. Implement member management (add/remove members)
//  4. Add expense splitting functionality
//  
//  Suggested API endpoints:
//  - GET /groups/{id} - Full group details
//  - GET /groups/{id}/members - List of members with details
//  - GET /groups/{id}/expenses - Group expenses
//  - GET /groups/{id}/balances - Member balances
//

import SwiftUI

struct GroupDetailView: View {
    
    // MARK: - Properties
    let group: GroupEntity
    
    // MARK: - Mock Members
    /// BACKEND NOTE: Replace with actual member data from API
    private var mockMembers: [ContactEntity] {
        [
            ContactEntity(fullName: "You", email: "me@gmail.com"),
            ContactEntity(fullName: "Sari Yulia", email: "saryulia@gmail.com"),
            ContactEntity(fullName: "Andi Sandika", email: "andi@gmail.com"),
            ContactEntity(fullName: "John Dioe", email: "john@gmail.com")
        ]
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // MARK: - Group Header
                groupHeader
                
                // MARK: - Members Section
                membersSection
                
                // MARK: - Actions Section
                actionsSection
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(group.name ?? "Untitled Group")
        .navigationBarTitleDisplayMode(.large)
    }
    
    // MARK: - Group Header
    private var groupHeader: some View {
        VStack(spacing: AppSpacing.md) {
            // Group Icon
            GroupIconView(group: group, size: .large)
            
            // Group Name
            Text(group.name ?? "Untitled Group")
                .font(.Title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // Member Count
            Text("\(group.memberCount > 0 ? group.memberCount : mockMembers.count) members")
                .font(.Subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.xl)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Members Section
    private var membersSection: some View {
        VStack(spacing: 0) {
            // Section Header
            ProfileSectionHeader(title: "MEMBERS")
            
            // Members List
            VStack(spacing: 0) {
                ForEach(Array(mockMembers.enumerated()), id: \.element.id) { index, member in
                    MemberRow(member: member, isCurrentUser: index == 0)
                    
                    if index < mockMembers.count - 1 {
                        Divider()
                            .padding(.leading, AppSpacing.lg + 40 + AppSpacing.md)
                    }
                }
            }
            .background(Color(.systemBackground))
        }
    }
    
    // MARK: - Actions Section
    private var actionsSection: some View {
        VStack(spacing: 0) {
            // Section Header
            ProfileSectionHeader(title: "ACTIONS")
            
            VStack(spacing: 0) {
                // View Expenses
                ActionRow(
                    icon: "list.bullet.rectangle",
                    title: "View Expenses",
                    iconColor: .blue
                ) {
                    // BACKEND NOTE: Navigate to group expenses list
                }
                
                Divider()
                    .padding(.leading, AppSpacing.lg + 40 + AppSpacing.md)
                
                // Add Expense
                ActionRow(
                    icon: "plus.circle.fill",
                    title: "Add Expense",
                    iconColor: .green
                ) {
                    // BACKEND NOTE: Navigate to add expense flow
                }
                
                Divider()
                    .padding(.leading, AppSpacing.lg + 40 + AppSpacing.md)
                
                // Settle Up
                ActionRow(
                    icon: "checkmark.circle.fill",
                    title: "Settle Up",
                    iconColor: .orange
                ) {
                    // BACKEND NOTE: Navigate to settle up flow
                }
                
                Divider()
                    .padding(.leading, AppSpacing.lg + 40 + AppSpacing.md)
                
                // Group Settings
                ActionRow(
                    icon: "gearshape.fill",
                    title: "Group Settings",
                    iconColor: .gray
                ) {
                    // BACKEND NOTE: Navigate to group settings
                }
            }
            .background(Color(.systemBackground))
        }
        .padding(.bottom, AppSpacing.xl)
    }
}

// MARK: - Member Row

private struct MemberRow: View {
    let member: ContactEntity
    let isCurrentUser: Bool
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            // Avatar
            ContactAvatarView(
                initials: member.initials,
                photoData: member.profilePhotoData,
                size: .small
            )
            
            // Name
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: AppSpacing.xs) {
                    Text(member.fullName ?? "Unknown")
                        .font(.Body)
                        .foregroundColor(.primary)
                    
                    if isCurrentUser {
                        Text("(You)")
                            .font(.Subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Text(member.email ?? "")
                    .font(.Caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.md)
    }
}

// MARK: - Action Row

private struct ActionRow: View {
    let icon: String
    let title: String
    let iconColor: Color
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: AppSpacing.md) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(iconColor)
                    .frame(width: 40, height: 40)
                
                // Title
                Text(title)
                    .font(.Body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)
        }
    }
}

//#Preview {
//    NavigationStack {
//        GroupDetailView(group: GroupEntity.mockGroupWithMembers())
//    }
//}
