//
//  AddFriendView.swift
//  Talangin
//
//  Created by Rifqi Rahman on 19/01/26.
//
//  Add friend sheet for searching and adding new friends by email or phone.
//
//  BACKEND DEVELOPER NOTES:
//  -------------------------
//  This view allows users to add new friends.
//  
//  Integration requirements:
//  1. Implement search API to find users by email/phone
//  2. Send friend request or add directly based on app flow
//  3. Handle cases: user not found, already friends, pending request
//  4. Consider implementing QR code scanning for easier adding
//  5. Sync new friends to CloudKit/server
//

import SwiftUI

struct AddFriendView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - State
    @State private var searchText: String = ""
    @State private var isSearching = false
    @State private var searchResults: [SearchResult] = []
    @State private var hasSearched = false
    @State private var showAddedAlert = false
    @State private var addedFriendName = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: - Search Section
                VStack(spacing: AppSpacing.md) {
                    // Search Field
                    HStack(spacing: AppSpacing.sm) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search by email or phone", text: $searchText)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .keyboardType(.emailAddress)
                            .onSubmit {
                                performSearch()
                            }
                        
                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                                searchResults = []
                                hasSearched = false
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(AppSpacing.md)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    // Search Button
                    Button {
                        performSearch()
                    } label: {
                        HStack {
                            if isSearching {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Search")
                                    .fontWeight(.semibold)
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.md)
                        .background(searchText.isEmpty ? AppColors.gray02 : AppColors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .disabled(searchText.isEmpty || isSearching)
                }
                .padding(AppSpacing.lg)
                
                Divider()
                
                // MARK: - Results Section
                if isSearching {
                    Spacer()
                    ProgressView("Searching...")
                    Spacer()
                } else if hasSearched && searchResults.isEmpty {
                    // No Results
                    emptyResultsView
                } else if !searchResults.isEmpty {
                    // Results List
                    resultsList
                } else {
                    // Initial State
                    initialStateView
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Add Friend")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Friend Added", isPresented: $showAddedAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("\(addedFriendName) has been added to your friends.")
            }
        }
    }
    
    // MARK: - Initial State View
    private var initialStateView: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()
            
            Image(systemName: "person.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text("Find Friends")
                .font(.Title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Search for friends by their email address or phone number to add them to your contacts.")
                .font(.Body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.xl)
            
            Spacer()
        }
    }
    
    // MARK: - Empty Results View
    private var emptyResultsView: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()
            
            Image(systemName: "person.slash")
                .font(.system(size: 60))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text("No Results Found")
                .font(.Title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("We couldn't find anyone with \"\(searchText)\". Make sure they have a Talangin account.")
                .font(.Body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.xl)
            
            // Invite Button
            Button {
                // BACKEND NOTE: Implement share/invite functionality
            } label: {
                Text("Invite to Talangin")
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.primary)
            }
            .padding(.top, AppSpacing.sm)
            
            Spacer()
        }
    }
    
    // MARK: - Results List
    private var resultsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(searchResults) { result in
                    SearchResultRow(result: result) {
                        addFriend(result)
                    }
                    
                    Divider()
                        .padding(.leading, AppSpacing.lg + 48)
                }
            }
            .background(Color(.systemBackground))
        }
    }
    
    // MARK: - Actions
    
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        
        isSearching = true
        hasSearched = true
        
        // BACKEND NOTE: Replace with actual API search
        // Simulating network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Mock results based on search text
            if searchText.lowercased().contains("test") || searchText.contains("@") {
                searchResults = [
                    SearchResult(
                        id: UUID(),
                        name: "Test User",
                        email: searchText.contains("@") ? searchText : "test@example.com",
                        initials: "TU"
                    )
                ]
            } else {
                searchResults = []
            }
            isSearching = false
        }
    }
    
    private func addFriend(_ result: SearchResult) {
        // BACKEND NOTE: Implement actual friend adding via repository
        addedFriendName = result.name
        showAddedAlert = true
    }
}

// MARK: - Search Result Model

struct SearchResult: Identifiable {
    let id: UUID
    let name: String
    let email: String
    let initials: String
}

// MARK: - Search Result Row

private struct SearchResultRow: View {
    let result: SearchResult
    let onAdd: () -> Void
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            // Avatar
            Text(result.initials)
                .font(.Body)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(width: 48, height: 48)
                .background(
                    Circle()
                        .fill(AppColors.primary.opacity(0.8))
                )
            
            // Info
            VStack(alignment: .leading, spacing: 2) {
                Text(result.name)
                    .font(.Body)
                    .foregroundColor(.primary)
                
                Text(result.email)
                    .font(.Caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Add Button
            Button {
                onAdd()
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(AppColors.primary)
            }
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.md)
    }
}

#Preview {
    AddFriendView()
}
