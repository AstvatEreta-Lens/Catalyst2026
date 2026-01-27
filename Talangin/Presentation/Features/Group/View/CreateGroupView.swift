//
//  CreateGroupView.swift
//  Talangin
//
//  Created by Rifqi Rahman on 27/01/26.
//
//  View for creating a new group.
//  Includes form for group name, profile picture, members selection, and payment due date.
//

import SwiftUI
import SwiftData
import UIKit

struct CreateGroupView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CreateEditGroupViewModel
    
    let currentUserID: UUID
    
    init(modelContext: ModelContext, currentUserID: UUID) {
        self.currentUserID = currentUserID
        _viewModel = StateObject(wrappedValue: CreateEditGroupViewModel(
            modelContext: modelContext,
            currentUserID: currentUserID
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
            .navigationTitle("New Group")
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
                MemberSelectionSheet(
                    modelContext: viewModel.modelContext,
                    initialSelectedMembers: viewModel.selectedMembers,
                    onDone: { selectedFriends in
                        viewModel.selectedMembers = selectedFriends
                    }
                )
            }
            .sheet(isPresented: $viewModel.showProfilePictureSheet) {
                ProfilePictureActionSheet(
                    groupPhotoData: $viewModel.groupPhotoData,
                    isEditMode: false
                )
                .presentationDetents([.fraction(0.33)])
                .presentationDragIndicator(.visible)
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred")
            }
            .onAppear {
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
                ZStack(alignment: .bottomTrailing) {
                    Group {
                        if let photoData = viewModel.groupPhotoData,
                           let uiImage = UIImage(data: photoData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                        } else {
                            ZStack {
                                // Background
                                Color(.systemBackground)
                                
                                // Placeholder icon
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.secondary)
                                    .frame(width: 40, height: 40)

                            }
                        }
                    }
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    // Camera icon circle (only show when no photo)
                    if viewModel.groupPhotoData == nil {
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.7))
                                .frame(width: 24, height: 24)
                            
                            Image(systemName: "pencil")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .offset(x: 4, y: 4)
                    }
                }
            }
            
            // Group Name TextField
            TextField("Group Name", text: $viewModel.groupName)
                .font(.body)
                .textFieldStyle(.plain)
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
                        Text("Select People")
                            .font(.body)
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
                            // Avatar with initials
                            Text(member.avatarInitials)
                                .font(.system(size: 14, weight: FontTokens.medium))
                                .foregroundColor(.blue)
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
            // Native inset row list style dengan DatePicker - tinggi sama dengan Members section
            HStack {
                // Label di kiri (tidak bisa diklik)
                Text("Payment due date")
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Native DatePicker di kanan (hanya ini yang bisa diklik)
                DatePicker(
                    "",
                    selection: Binding(
                        get: {
                            // Gunakan tanggal yang ada, atau hitung default dari last expense, atau 7 hari dari sekarang
                            viewModel.paymentDueDate ?? viewModel.calculateDefaultPaymentDueDate()
                        },
                        set: { newDate in
                            viewModel.paymentDueDate = newDate
                        }
                    ),
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .labelsHidden()
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Text("It's set to 7 days after the last expense by default")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Previews
#Preview("Create Group View") {
    // Use the same schema as the main app to ensure consistency
    let schema = Schema([
        UserEntity.self,
        PaymentMethodEntity.self,
        ExpenseEntity.self,
        GroupEntity.self,
        FriendEntity.self,
        SplitParticipantEntity.self,
        ExpenseItemEntity.self,
        ContactEntity.self,
        ContactPaymentMethod.self
    ])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    
    // Create container with proper error handling
    do {
        let container = try ModelContainer(for: schema, configurations: [config])
        let context = container.mainContext
        let currentUserID = UUID(uuidString: "00000000-0000-0000-0000-000000000001") ?? UUID()
        
        // Create dummy friends similar to BeneficiarySelectionViewModel
        let friend1 = FriendEntity(userId: "user1", fullName: "Budi")
        friend1.id = UUID(uuidString: "00000000-0000-0000-0000-000000000002") ?? UUID()
        context.insert(friend1)
        
        let friend2 = FriendEntity(userId: "user2", fullName: "Santoso")
        friend2.id = UUID(uuidString: "00000000-0000-0000-0000-000000000003") ?? UUID()
        context.insert(friend2)
        
        let friend3 = FriendEntity(userId: "user3", fullName: "Ria")
        friend3.id = UUID(uuidString: "00000000-0000-0000-0000-000000000004") ?? UUID()
        context.insert(friend3)
        
        let friend4 = FriendEntity(userId: "user4", fullName: "Ahmad Luthfi")
        friend4.id = UUID(uuidString: "00000000-0000-0000-0000-000000000005") ?? UUID()
        context.insert(friend4)
        
        let friend5 = FriendEntity(userId: "user5", fullName: "Rudi Qomarudin")
        friend5.id = UUID(uuidString: "00000000-0000-0000-0000-000000000006") ?? UUID()
        context.insert(friend5)
        
        // Save context
        try context.save()
        
        return NavigationStack {
            CreateGroupView(
                modelContext: context,
                currentUserID: currentUserID
            )
        }
        .modelContainer(container)
    } catch {
        return VStack {
            Text("Preview Error")
                .font(.headline)
            Text(error.localizedDescription)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding()
        }
    }
}
//
//#Preview("Date Picker Sheet") {
//    DatePickerSheet(selectedDate: .constant(Date()))
//        .presentationDetents([.medium])
//        .presentationDragIndicator(.visible)
//}
