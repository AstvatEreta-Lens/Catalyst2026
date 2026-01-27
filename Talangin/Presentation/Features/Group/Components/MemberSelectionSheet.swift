//
//  MemberSelectionSheet.swift
//  Talangin
//
//  Created by Rifqi Rahman on 27/01/26.
//
//  Sheet for selecting group members from friends list.
//  Supports search functionality and displays selected members at the top.
//

import SwiftUI
import SwiftData
import UIKit

struct MemberSelectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CreateEditGroupViewModel
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        if !viewModel.selectedMembers.isEmpty {
                            selectedMembersCard
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }
                        
                        recentFriendsSection
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 100)
                }
                
                footerView
            }
            .navigationTitle("Members")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(
                text: $viewModel.searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search name"
            )
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .animation(.default, value: viewModel.selectedMembers)
        }
    }
    
    // MARK: - Selected Members Card
    private var selectedMembersCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(viewModel.selectedMembers) { member in
                        VStack(spacing: 8) {
                            ZStack(alignment: .topTrailing) {
                                // Avatar
                                Group {
                                    if let photoData = member.profilePhotoData,
                                       let uiImage = UIImage(data: photoData) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                    } else {
                                        Text(member.avatarInitials)
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundColor(.blue)
                                    }
                                }
                                .frame(width: 56, height: 56)
                                .background(Color(red: 0.9, green: 0.93, blue: 0.98))
                                .clipShape(Circle())
                                
                                // Remove button
                                Button {
                                    viewModel.removeMember(member)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.gray)
                                        .background(Circle().fill(Color.white))
                                        .font(.system(size: 20))
                                }
                                .offset(x: 8, y: -8)
                            }
                            
                            Text(member.fullName ?? "Unknown")
                                .font(.caption)
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
    
    // MARK: - Recent Friends Section
    private var recentFriendsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Friends")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                // Add New Friend Row
                Button {
                    // TODO: Navigate to Add Friend
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
                            .font(.body)
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
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)
        }
    }
    
    // MARK: - Friend Row
    private func friendRow(_ friend: FriendEntity) -> some View {
        HStack(spacing: 16) {
            Button {
                viewModel.toggleMemberSelection(friend)
            } label: {
                selectionCheckbox(isSelected: viewModel.isMemberSelected(friend))
            }
            
            // Avatar
            Group {
                if let photoData = friend.profilePhotoData,
                   let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Text(friend.avatarInitials)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.blue)
                }
            }
            .frame(width: 32, height: 32)
            .background(Color(red: 0.9, green: 0.93, blue: 0.98))
            .clipShape(Circle())
            
            Text(friend.fullName ?? "Unknown")
                .font(.body)
                .foregroundColor(.black)
            
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal)
    }
    
    // MARK: - Selection Checkbox
    private func selectionCheckbox(isSelected: Bool) -> some View {
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
    
    // MARK: - Footer View
    private var footerView: some View {
        VStack {
            Spacer()
            Color.white
                .frame(height: 100)
                .ignoresSafeArea()
        }
    }
}

#Preview {
    let schema = Schema([
        GroupEntity.self,
        FriendEntity.self,
        UserEntity.self,
        ExpenseEntity.self,
        ExpenseItemEntity.self,
        SplitParticipantEntity.self
    ])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    
    guard let container = try? ModelContainer(for: schema, configurations: [config]) else {
        return Text("Failed to create preview container")
    }
    
    let context = container.mainContext
    
    // Add some mock friends for preview
    let friend1 = FriendEntity(userId: "user1", fullName: "John Doe")
    let friend2 = FriendEntity(userId: "user2", fullName: "Jane Smith")
    context.insert(friend1)
    context.insert(friend2)
    
    return NavigationStack {
        MemberSelectionSheet(viewModel: CreateEditGroupViewModel(
            modelContext: context,
            currentUserID: UUID(uuidString: "00000000-0000-0000-0000-000000000001") ?? UUID()
        ))
    }
    .modelContainer(container)
}
