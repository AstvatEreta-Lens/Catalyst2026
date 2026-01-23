//
//  GroupDetailView.swift
//  Talangin
//
//  Created by Rifqi Rahman on 19/01/26.
//
//  Group detail view using native SwiftUI List component.
//  Shows group info, members, and action buttons.
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
        List {
            // MARK: - Group Header
            Section {
                VStack(spacing: AppSpacing.md) {
                    GroupIconView(group: group, size: .large)
                    
                    Text(group.name)
                        .font(.Title2)
                        .fontWeight(.bold)
                    
                    Text("\(group.memberCount > 0 ? group.memberCount : mockMembers.count) members")
                        .font(.Subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.lg)
                .listRowBackground(Color(.systemBackground))
            }
            
            // MARK: - Members Section
            Section {
                ForEach(Array(mockMembers.enumerated()), id: \.element.id) { index, member in
                    HStack(spacing: AppSpacing.md) {
                        ContactAvatarView(
                            initials: member.initials,
                            photoData: member.profilePhotoData,
                            size: .small
                        )
                        
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: AppSpacing.xs) {
                                Text(member.fullName)
                                
                                if index == 0 {
                                    Text("(You)")
                                        .font(.Subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Text(member.email)
                                .font(.Caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            } header: {
                Text("MEMBERS")
            }
            
            // MARK: - Actions Section
            Section {
                // View Expenses
                Button {
                    // BACKEND NOTE: Navigate to group expenses list
                } label: {
                    Label {
                        Text("View Expenses")
                            .foregroundColor(.primary)
                    } icon: {
                        Image(systemName: "list.bullet.rectangle")
                            .foregroundColor(.blue)
                    }
                }
                
                // Add Expense
                Button {
                    // BACKEND NOTE: Navigate to add expense flow
                } label: {
                    Label {
                        Text("Add Expense")
                            .foregroundColor(.primary)
                    } icon: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(AppColors.success)
                    }
                }
                
                // Settle Up
                Button {
                    // BACKEND NOTE: Navigate to settle up flow
                } label: {
                    Label {
                        Text("Settle Up")
                            .foregroundColor(.primary)
                    } icon: {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.orange)
                    }
                }
                
                // Group Settings
                Button {
                    // BACKEND NOTE: Navigate to group settings
                } label: {
                    Label {
                        Text("Group Settings")
                            .foregroundColor(.primary)
                    } icon: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.gray)
                    }
                }
            } header: {
                Text("ACTIONS")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(group.name)
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        GroupDetailView(group: GroupEntity.mockGroupWithMembers())
    }
}
