//
//  MemberSelectionSheet.swift
//  Talangin
//
//  Created by Rifqi Rahman on 27/01/26.
//
//  Sheet for selecting group members from friends list.
//  Reuses view structure and logic from BeneficiarySelectionSheet.
//

import SwiftUI
import SwiftData
import UIKit

struct MemberSelectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: MemberSelectionViewModel
    let onDone: ([FriendEntity]) -> Void
    
    init(modelContext: ModelContext, initialSelectedMembers: [FriendEntity] = [], onDone: @escaping ([FriendEntity]) -> Void) {
        self.onDone = onDone
        _viewModel = State(initialValue: MemberSelectionViewModel(
            modelContext: modelContext,
            initialSelectedMembers: initialSelectedMembers
        ))
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        if !viewModel.allSelectedMembers.isEmpty {
                            selectedMembersCard
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }
                        
                        recentFriendsSection
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Members")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(
                text: $viewModel.searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search name"
            )
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        let selectedFriends = viewModel.getSelectedFriends()
                        onDone(selectedFriends)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .animation(.default, value: viewModel.allSelectedMembers)
        }
    }
    
    // MARK: - Selected Members Card
    private var selectedMembersCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(viewModel.allSelectedMembers) { member in
                        VStack(spacing: 8) {
                            ZStack(alignment: .topTrailing) {
                                // Avatar with initials (like BeneficiarySelectionSheet)
                                Text(member.initials)
                                    .font(.system(size: FontTokens.Callout.size, weight: FontTokens.medium))
                                    .foregroundColor(.blue)
                                    .frame(width: 56, height: 56)
                                    .background(Color(red: 0.9, green: 0.93, blue: 0.98))
                                    .clipShape(Circle())
                                
                                // Remove button
                                if let friend = viewModel.friends.first(where: { $0.id == member.id }) {
                                    Button {
                                        viewModel.removeFriend(friend)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.gray)
                                            .background(Circle().fill(Color.white))
                                            .font(.system(size: 20))
                                    }
                                    .offset(x: 8, y: -8)
                                }
                            }
                            
                            Text(member.name)
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
            Text("Friends")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                // Add New Friend TextField
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(width: 32, height: 32)
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.gray)
                    }
                    
                    TextField("Add New Friend", text: $viewModel.newFriendName)
                        .font(.body)
                        .foregroundColor(.gray.opacity(0.6))
                        .submitLabel(.done)
                        .onSubmit {
                            viewModel.createNewFriend()
                        }
                    
                    // Submit button (appears when text is not empty)
                    if !viewModel.newFriendName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Button {
                            viewModel.createNewFriend()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal)
                
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
}

// MARK: - Private Extension
private extension MemberSelectionSheet {
    func friendRow(_ friend: FriendEntity) -> some View {
        HStack(spacing: 16) {
            Button {
                viewModel.toggleFriendSelection(friend)
            } label: {
                selectionCheckbox(isSelected: viewModel.isFriendSelected(friend))
            }
            
            // Avatar with initials (like BeneficiarySelectionSheet)
            Text(friend.avatarInitials)
                .font(.system(size: 14, weight: FontTokens.medium))
                .foregroundColor(.blue)
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
    let schema = Schema([
        GroupEntity.self,
        FriendEntity.self,
        UserEntity.self,
        ExpenseEntity.self,
        ExpenseItemEntity.self,
        SplitParticipantEntity.self,
        ContactEntity.self,
        ContactPaymentMethod.self,
        PaymentMethodEntity.self
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
        MemberSelectionSheet(
            modelContext: context,
            initialSelectedMembers: [friend1],
            onDone: { selectedFriends in
                print("Selected friends: \(selectedFriends.count)")
            }
        )
    }
    .modelContainer(container)
}
