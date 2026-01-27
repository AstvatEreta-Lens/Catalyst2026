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
    
    init(modelContext: ModelContext, currentUserID: UUID) {
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
                MemberSelectionSheet(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showProfilePictureSheet) {
                ProfilePictureActionSheet(
                    groupPhotoData: $viewModel.groupPhotoData,
                    isEditMode: false
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
            TextField("Group Name", text: $viewModel.groupName)
                .font(.title3)
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
            
            Button {
                viewModel.showMemberSelection = true
            } label: {
                HStack {
                    Text(viewModel.membersText)
                        .foregroundColor(viewModel.selectedMembers.isEmpty ? .secondary : .primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .padding()
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

// MARK: - Date Picker Sheet
struct DatePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDate: Date?
    @State private var tempDate: Date
    
    init(selectedDate: Binding<Date?>) {
        self._selectedDate = selectedDate
        self._tempDate = State(initialValue: selectedDate.wrappedValue ?? Date())
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                DatePicker(
                    "Select Date",
                    selection: $tempDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                
                Spacer()
            }
            .padding()
            .navigationTitle("Payment Due Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        selectedDate = tempDate
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
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
