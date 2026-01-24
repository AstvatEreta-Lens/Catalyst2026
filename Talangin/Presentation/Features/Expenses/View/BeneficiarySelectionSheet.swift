//
//  BeneficiarySelectionSheet.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 12/01/26.
//

import SwiftUI

struct BeneficiarySelectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = BeneficiarySelectionViewModel()
    let onDone: ([FriendEntity], [GroupEntity]) -> Void
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        if !viewModel.allSelectedBeneficiaries.isEmpty {
                            selectedMembersCard
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }
                        
                        recentFriendsSection
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Add Penerima manfaat")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search people")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        let selectedFriends = viewModel.friends.filter { viewModel.selectedFriendIds.contains($0.id ?? UUID()) }
                        let selectedGroups = viewModel.groups.filter { viewModel.selectedGroupIds.contains($0.id ?? UUID()) }
                        
                        onDone(selectedFriends, selectedGroups)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .animation(.default, value: viewModel.allSelectedBeneficiaries)
        }
    }
    
    private var selectedMembersCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(viewModel.allSelectedBeneficiaries) { beneficiary in
                        VStack(spacing: 8) {
                            ZStack(alignment: .topTrailing) {
                                Text(beneficiary.initials)
                                    .font(.system(size: FontTokens.Callout.size, weight: FontTokens.medium))
                                    .foregroundColor(.blue)
                                    .frame(width: 56, height: 56)
                                    .background(Color(red: 0.9, green: 0.93, blue: 0.98))
                                    .clipShape(Circle())
                                
                                Button {
                                    if beneficiary.isFriend {
                                        if let friend = viewModel.friends.first(where: { $0.id == beneficiary.id }) {
                                            viewModel.toggleFriendSelection(friend)
                                        }
                                    } else {
                                        if let group = viewModel.groups.first(where: { $0.id == beneficiary.id }) {
                                            viewModel.toggleGroupSelection(group)
                                        }
                                    }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.gray)
                                        .background(Circle().fill(Color.white))
                                        .font(.system(size: 20))
                                }
                                .offset(x: 8, y: -8)
                            }
                            
                            Text(beneficiary.name)
                                .font(.Caption)
                                .lineLimit(1)
                                .frame(width: 60)
                        }
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 4)
            }
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
    
    private var recentFriendsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Friends")
                .font(.Headline)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                // Add New Friend Row
                Button {
                    // TODO: Action to add friend
                } label: {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: 32, height: 32)
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.gray)
                        }
                        
                        Text("Add New Friend")
                            .font(.Body)
                            .foregroundColor(.gray.opacity(0.6))
                        
                        Spacer()
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal)
                }
                
                Divider()
                    .padding(.leading, 60)
                
                // Friends List
                ForEach(viewModel.filteredFriends) { friend in
                    friendRow(friend)
                    
                    if friend != viewModel.filteredFriends.last {
                        Divider()
                            .padding(.leading, 60)
                    }
                }
                
                // Groups Section (Optional, but viewModel has groups)
                if !viewModel.filteredGroups.isEmpty {
                    Divider()
                        .padding(.leading, 60)
                    
                    ForEach(viewModel.filteredGroups) { group in
                        groupRow(group)
                        
                        if group != viewModel.filteredGroups.last {
                            Divider()
                                .padding(.leading, 60)
                        }
                    }
                }
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)
        }
    }
}

private extension BeneficiarySelectionSheet {
    func friendRow(_ friend: FriendEntity) -> some View {
        HStack(spacing: 16) {
            Button {
                viewModel.toggleFriendSelection(friend)
            } label: {
                selectionCheckbox(isSelected: viewModel.isFriendSelected(friend))
            }

            Text(friend.fullName ?? "Unknown")
                .font(.Body)
                .foregroundColor(.black)
            
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal)
    }
    
    func groupRow(_ group: GroupEntity) -> some View {
        HStack(spacing: 16) {
            Button {
                viewModel.toggleGroupSelection(group)
            } label: {
                selectionCheckbox(isSelected: viewModel.isGroupSelected(group))
            }

            Text(group.name ?? "Unknown")
                .font(.Body)
                .foregroundColor(.black)
            
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal)
    }
    
    func selectionCheckbox(isSelected: Bool) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color(red: 0.2, green: 0.78, blue: 0.35) : Color.clear)
                .frame(width: 24, height: 24)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 2)
                )
            
            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    BeneficiarySelectionSheet { friends, groups in
        print("Selected friends: \(friends.count)")
        print("Selected groups: \(groups.count)")
    }
}
