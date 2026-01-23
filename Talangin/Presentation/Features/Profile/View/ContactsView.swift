//
//  ContactsView.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 15/01/26.
//
//  People and Groups view using native SwiftUI List component.
//  Features Friends/Groups segmented control and search functionality.
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
            // MARK: - Segmented Control
            Picker("Contacts Tab", selection: $selectedTab) {
                Text("Friends").tag(ContactsTab.friends)
                Text("Groups").tag(ContactsTab.groups)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)
            
            // MARK: - Content List
            List {
                switch selectedTab {
                case .friends:
                    friendsListContent
                case .groups:
                    groupsListContent
                }
            }
            .listStyle(.insetGrouped)
            .searchable(text: $searchText, prompt: "Search name")
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("People and Groups")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showAddFriend) {
            AddFriendView()
        }
    }
    
    // MARK: - Friends List Content
    @ViewBuilder
    private var friendsListContent: some View {
        // Add New Friend Button
        Section {
            Button {
                showAddFriend = true
            } label: {
                HStack(spacing: AppSpacing.md) {
                    ZStack {
                        Circle()
                            .fill(Color(.systemGray5))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Text("Add New Friend")
                        .foregroundColor(.secondary)
                }
            }
        }
        
        // Friends List
        Section {
            ForEach(filteredContactsList) { contact in
                NavigationLink {
                    FriendDetailView(contact: contact, sharedGroups: getSharedGroups(for: contact))
                } label: {
                    HStack(spacing: AppSpacing.md) {
                        ContactAvatarView(
                            initials: contact.initials,
                            photoData: contact.profilePhotoData,
                            size: .small
                        )
                        
                        Text(contact.fullName)
                    }
                }
            }
        }
    }
    
    // MARK: - Groups List Content
    @ViewBuilder
    private var groupsListContent: some View {
        Section {
            ForEach(filteredGroupsList) { group in
                NavigationLink {
                    GroupDetailView(group: group)
                } label: {
                    HStack(spacing: AppSpacing.md) {
                        GroupIconView(group: group, size: .small)
                        
                        Text(group.name)
                    }
                }
            }
        }
    }
    
    // MARK: - Filtered Lists
    
    private var filteredContactsList: [ContactEntity] {
        guard !searchText.isEmpty else {
            return mockContacts
        }
        return mockContacts.filter { contact in
            contact.fullName.localizedCaseInsensitiveContains(searchText) ||
            contact.email.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private var filteredGroupsList: [GroupEntity] {
        guard !searchText.isEmpty else {
            return mockGroups
        }
        return mockGroups.filter { group in
            group.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    // MARK: - Helper Methods
    
    /// Returns shared groups for a contact
    /// BACKEND NOTE: Replace with actual shared groups lookup
    private func getSharedGroups(for contact: ContactEntity) -> [GroupEntity] {
        Array(mockGroups.prefix(2))
    }
}

// MARK: - Supporting Types

private enum ContactsTab {
    case friends
    case groups
}

#Preview {
    NavigationStack {
        ContactsView()
    }
}
