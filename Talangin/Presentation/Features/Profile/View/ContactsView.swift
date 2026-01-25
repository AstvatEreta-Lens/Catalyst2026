//
//  ContactsView.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 15/01/26.
//
//  People and Groups view with Friends/Groups segmented control and search functionality.
//  Updated: Added proper group icons, integrated with ContactEntity and GroupEntity models.
//
//  BACKEND DEVELOPER NOTES:
//  -------------------------
//  This view currently uses mock data. To integrate with backend:
//  1. Replace mockContacts with data from ContactEntity repository
//  2. Replace mockGroups with data from GroupEntity repository
//  3. Implement search functionality via API or local filtering
//  4. Add pull-to-refresh for data synchronization
//

import SwiftUI

struct ContactsView: View {
    @State private var selectedTab: ContactsTab = .friends
    @State private var searchText: String = ""
    @State private var showAddFriend = false
    
    // MARK: - Mock Data
    /// BACKEND NOTE: Replace with actual data from repositories
    private var mockContacts: [ContactEntity] {
        ContactEntity.mockContacts
    }
    
    private var mockGroups: [GroupEntity] {
        GroupEntity.mockGroups
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Search Bar
            searchBarSection
            
            // MARK: - Segmented Control
            Picker("Contacts Tab", selection: $selectedTab) {
                Text("Friends").tag(ContactsTab.friends)
                Text("Groups").tag(ContactsTab.groups)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, AppSpacing.lg)
            .padding(.bottom, AppSpacing.md)
            
            // MARK: - Content List
            ScrollView {
                VStack(spacing: 0) {
                    switch selectedTab {
                    case .friends:
                        friendsList
                    case .groups:
                        groupsList
                    }
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("People and Groups")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showAddFriend) {
            AddFriendView()
        }
    }
    
    // MARK: - Search Bar Section
    private var searchBarSection: some View {
        HStack(spacing: AppSpacing.sm) {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search name", text: $searchText)
                    .font(.Body)
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            Button {
                // BACKEND NOTE: Implement speech recognition
            } label: {
                Image(systemName: "mic.fill")
                    .foregroundColor(AppColors.primary)
                    .font(.system(size: 20))
            }
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.md)
    }
    
    // MARK: - Friends List
    @ViewBuilder
    private var friendsList: some View {
        VStack(spacing: 0) {
            // Add New Friend Button
            addNewFriendButton
            
            // Friends List
            let filteredFriends = filteredContactsList
            ForEach(Array(filteredFriends.enumerated()), id: \.element.id) { index, contact in
                NavigationLink {
                    FriendDetailView(contact: contact, sharedGroups: getSharedGroups(for: contact))
                } label: {
                    ContactRowView(contact: contact)
                }
                .buttonStyle(PlainButtonStyle())
                
                if index < filteredFriends.count - 1 {
                    Divider()
                        .padding(.leading, AppSpacing.lg + 40 + AppSpacing.md)
                }
            }
        }
        .background(Color(.systemBackground))
    }
    
    // MARK: - Add New Friend Button
    @ViewBuilder
    private var addNewFriendButton: some View {
        Button {
            showAddFriend = true
        } label: {
            HStack(spacing: AppSpacing.md) {
                ZStack {
                    Circle()
                        .fill(Color(.systemGray5))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "plus")
                        .font(.system(size: FontTokens.Callout.size, weight: FontTokens.medium))
                        .foregroundColor(.secondary)
                }
                
                Text("Add New Friend")
                    .foregroundColor(.secondary)
                    .font(.Body)
                
                Spacer()
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)
            .background(Color(.systemBackground))
        }
        
        Divider()
            .padding(.leading, AppSpacing.lg + 40 + AppSpacing.md)
    }
    
    // MARK: - Groups List
    @ViewBuilder
    private var groupsList: some View {
        VStack(spacing: 0) {
            let filteredGroups = filteredGroupsList
            ForEach(Array(filteredGroups.enumerated()), id: \.element.id) { index, group in
                NavigationLink {
                    GroupDetailView(group: group)
                } label: {
                    GroupRowView(group: group)
                }
                .buttonStyle(PlainButtonStyle())
                
                if index < filteredGroups.count - 1 {
                    Divider()
                        .padding(.leading, AppSpacing.lg + 40 + AppSpacing.md)
                }
            }
        }
        .background(Color(.systemBackground))
    }
    
    // MARK: - Filtered Lists
    
    private var filteredContactsList: [ContactEntity] {
        guard !searchText.isEmpty else {
            return mockContacts
        }

        return mockContacts.filter { contact in
            (contact.fullName ?? "")
                .localizedCaseInsensitiveContains(searchText)
            ||
            (contact.email ?? "")
                .localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private var filteredGroupsList: [GroupEntity] {
        guard !searchText.isEmpty else {
            return mockGroups
        }
        return mockGroups.filter { group in
            (group.name ?? "").localizedCaseInsensitiveContains(searchText)
        }
    }
    
    // MARK: - Helper Methods
    
    /// Returns shared groups for a contact
    /// BACKEND NOTE: Replace with actual shared groups lookup
    private func getSharedGroups(for contact: ContactEntity) -> [GroupEntity] {
        // Mock: Return first 2 groups as shared
        Array(mockGroups.prefix(2))
    }
}

// MARK: - Supporting Types

private enum ContactsTab {
    case friends
    case groups
}

// MARK: - Contact Row View

private struct ContactRowView: View {
    let contact: ContactEntity
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            // Avatar
            ContactAvatarView(
                initials: contact.initials,
                photoData: contact.profilePhotoData,
                size: .small
            )
            
            // Name
            Text(contact.fullName ?? "Unknown Contact")
                .font(.Body)
                .foregroundColor(.primary)
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: FontTokens.medium))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.md)
        .background(Color(.systemBackground))
    }
}

// MARK: - Group Row View

private struct GroupRowView: View {
    let group: GroupEntity
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            // Group Icon
            GroupIconView(group: group, size: .small)
            
            // Group Name
            Text(group.name ?? "Untitled")
                .font(.Body)
                .foregroundColor(.primary)
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: FontTokens.medium))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.md)
        .background(Color(.systemBackground))
    }
}

#Preview {
    NavigationStack {
        ContactsView()
    }
}
