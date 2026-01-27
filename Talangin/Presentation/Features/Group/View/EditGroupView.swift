//
//  EditGroupView.swift
//  Talangin
//
//  Created by Rifqi Rahman on 27/01/26.
//
//  View for editing an existing group.
//  Similar to CreateGroupView but pre-populated with existing group data.
//

import SwiftUI
import SwiftData
import UIKit

struct EditGroupView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CreateEditGroupViewModel
    
    let group: GroupEntity
    let currentUserID: UUID
    
    init(group: GroupEntity, currentUserID: UUID, modelContext: ModelContext) {
        self.group = group
        self.currentUserID = currentUserID
        _viewModel = StateObject(wrappedValue: CreateEditGroupViewModel(
            modelContext: modelContext,
            currentUserID: currentUserID,
            existingGroup: group
        ))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Group Profile Picture & Name Section
                        groupProfileSection
                        
                        // Members Section
                        membersSection
                        
                        // Payment Due Date Section
                        paymentDueDateSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Edit Group")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Home")
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Create") {
                        viewModel.saveGroup {
                            dismiss()
                        }
                    }
                    .fontWeight(.semibold)
                    .disabled(!viewModel.canSave || viewModel.isLoading)
                }
            }
            .sheet(isPresented: $viewModel.showMemberSelection) {
                MemberSelectionSheet(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showProfilePictureSheet) {
                ProfilePictureActionSheet(
                    groupPhotoData: $viewModel.groupPhotoData,
                    isEditMode: true
                )
                .presentationDetents([.fraction(0.33)])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $viewModel.showDatePicker) {
                DatePickerSheet(selectedDate: $viewModel.paymentDueDate)
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred")
            }
            .onAppear {
                // Load group data including relationships (must be on MainActor)
                viewModel.loadGroupData()
                // Reload friends to ensure data is fresh and handle any init errors
                viewModel.reloadFriends()
            }
        }
    }
    
    // MARK: - Group Profile Section
    private var groupProfileSection: some View {
        HStack(spacing: 16) {
            // Profile Picture Button
            Button {
                viewModel.showProfilePictureSheet = true
            } label: {
                Group {
                    if let photoData = viewModel.groupPhotoData,
                       let uiImage = UIImage(data: photoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.1))
                            Image(systemName: "camera.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.gray)
                        }
                    }
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            // Group Name TextField
            HStack {
                TextField("Group Name", text: $viewModel.groupName)
                    .font(.title3)
                    .textFieldStyle(.plain)
                
                if !viewModel.groupName.isEmpty {
                    Button {
                        viewModel.groupName = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    // MARK: - Members Section
    private var membersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Members")
                .font(.headline)
                .foregroundColor(.primary)
            
            if viewModel.selectedMembers.isEmpty {
                Button {
                    viewModel.showMemberSelection = true
                } label: {
                    HStack {
                        Text(viewModel.membersText)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            } else {
                VStack(spacing: 0) {
                    ForEach(viewModel.selectedMembers) { member in
                        HStack(spacing: 12) {
                            // Avatar
                            Group {
                                if let photoData = member.profilePhotoData,
                                   let uiImage = UIImage(data: photoData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                } else {
                                    Text(member.avatarInitials)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.blue)
                                }
                            }
                            .frame(width: 32, height: 32)
                            .background(Color(red: 0.9, green: 0.93, blue: 0.98))
                            .clipShape(Circle())
                            
                            Text(member.fullName ?? "Unknown")
                                .font(.body)
                            
                            // Show "(Me)" for current user
                            if let memberId = member.id, memberId == currentUserID {
                                Text("(Me)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            // Remove button (don't show for current user)
                            if let memberId = member.id, memberId != currentUserID {
                                Button {
                                    viewModel.removeMember(member)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal)
                        
                        if let currentMemberId = member.id,
                           let lastMemberId = viewModel.selectedMembers.last?.id,
                           currentMemberId != lastMemberId {
                            Divider()
                                .padding(.leading, 56)
                        }
                    }
                    
                    // Add more members button
                    Button {
                        viewModel.showMemberSelection = true
                    } label: {
                        HStack {
                            Text("Select People")
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal)
                    }
                }
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
    // MARK: - Payment Due Date Section
    private var paymentDueDateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Payment Due Date")
                .font(.headline)
                .foregroundColor(.primary)
            
            Button {
                viewModel.showDatePicker = true
            } label: {
                HStack {
                    Text(viewModel.paymentDueDateText)
                        .foregroundColor(viewModel.paymentDueDate == nil ? .secondary : .primary)
                    
                    Spacer()
                    
                    Image(systemName: "calendar")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            Text("It's set to 7 days after the last expense by default")
                .font(.caption)
                .foregroundColor(.secondary)
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
    let group = GroupEntity(name: "Test Group")
    context.insert(group)
    
    return NavigationStack {
        EditGroupView(
            group: group,
            currentUserID: UUID(uuidString: "00000000-0000-0000-0000-000000000001") ?? UUID(),
            modelContext: context
        )
    }
    .modelContainer(container)
}
