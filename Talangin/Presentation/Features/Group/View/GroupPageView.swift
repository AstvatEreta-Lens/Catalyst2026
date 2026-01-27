//
//  GroupPageView.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 16/01/26.
//

//Harusnya ini gak kepake, karena view nya ada yang sudah lebih rapih, dan ada 3 segmented controls: summary, expeneses, dan members, dengan fungsi untuk share invoice juga. So, ini gak kepake.

import SwiftUI
import SwiftData

struct GroupPageView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: GroupPageViewModel
    @State private var showEditGroup = false
    
    let currentUserID: UUID
    
    init(group: GroupEntity, currentUserID: UUID, modelContext: ModelContext) {
        self.currentUserID = currentUserID
        _viewModel = StateObject(wrappedValue: GroupPageViewModel(
            group: group,
            currentUserID: currentUserID,
            modelContext: modelContext
        ))
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            backgroundView
            
            ScrollView {
                VStack(spacing: 0) {
                    GroupPageHeaderView(viewModel: viewModel)
                    
                    VStack(spacing: 20) {
                        GroupSegmentedPicker(
                            selectedTab: $viewModel.selectedTab,
                            tabs: ["Summary", "Expenses", "Members"]
                        )
                        
                        tabContentView
                            .padding(.bottom, 100)
                    }
                    .padding()
                }
            }
         
            
            VStack {
                Spacer()
                AddExpenseFloatingButton {
                    viewModel.showAddExpenseSheet = true
                }
                .padding(.bottom, 16)
            }
        }
        .ignoresSafeArea(edges: .top)
        .sheet(isPresented: $viewModel.showAddExpenseSheet) {
            AddNewExpenseView(group: viewModel.group)
        }
        .sheet(isPresented: $viewModel.isEditingName) {
            EditGroupNameSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $showEditGroup) {
            EditGroupView(
                group: viewModel.group,
                currentUserID: currentUserID,
                modelContext: modelContext
            )
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) { backButton }
            ToolbarItem(placement: .topBarTrailing) { toolbarActions }
        }
        .alert("Delete Group", isPresented: $viewModel.showDeleteConfirmation) {
            deleteAlertButtons
        } message: {
            Text("Are you sure you want to delete '\(viewModel.groupName)'? This action cannot be undone.")
        }
    }
}

// MARK: - Subviews
private extension GroupPageView {
    var backgroundView: some View {
        Color(uiColor: .systemGroupedBackground)
            .ignoresSafeArea()
    }
    
    var backButton: some View {
        Button {
            dismiss()
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                Text("Home")
            }
            .foregroundColor(.white)
        }
    }
    
    var toolbarActions: some View {
        HStack(spacing: 12) {
            NavigationLink {
                ProfileView()
            } label: {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.white)
            }
            
            Menu {
                Button {
                    showEditGroup = true
                } label: {
                    Label("Edit Group", systemImage: "pencil")
                }
                
                Button(role: .destructive) {
                    viewModel.showDeleteConfirmation = true
                } label: {
                    Label("Delete Group", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle.fill")
                    .font(.title3)
                    .foregroundColor(.white)
            }
        }
    }
    
    var deleteAlertButtons: some View {
        Group {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel.deleteGroup {
                    dismiss()
                }
            }
        }
    }
    
    @ViewBuilder
    var tabContentView: some View {
        switch viewModel.selectedTab {
        case 0:
            GroupSummaryTab(viewModel: viewModel)
        case 1:
            GroupExpensesTab(viewModel: viewModel)
        case 2:
            GroupMembersTab(viewModel: viewModel)
        default:
            EmptyView()
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

#Preview("Edit Group View") {
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
        
        // Create dummy friends with realistic data
        let friend1 = FriendEntity(userId: "user1", fullName: "John Dioe")
        friend1.id = UUID(uuidString: "00000000-0000-0000-0000-000000000002") ?? UUID()
        context.insert(friend1)
        
        let friend2 = FriendEntity(userId: "user2", fullName: "Andi Sandika")
        friend2.id = UUID(uuidString: "00000000-0000-0000-0000-000000000003") ?? UUID()
        context.insert(friend2)
        
        let friend3 = FriendEntity(userId: "user3", fullName: "Sari Yulia")
        friend3.id = UUID(uuidString: "00000000-0000-0000-0000-000000000004") ?? UUID()
        context.insert(friend3)
        
        // Create group with multiple members and payment due date
        let group = GroupEntity(name: "Talangin")
        group.id = UUID(uuidString: "00000000-0000-0000-0000-000000000010") ?? UUID()
        group.paymentDueDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())
        group.members = [friend1, friend2, friend3]
        group.createdAt = Calendar.current.date(byAdding: .day, value: -30, to: Date())
        group.updatedAt = Date()
        context.insert(group)
        
        // Create some expenses for the group
        let expense1 = ExpenseEntity(
            title: "Dinner at Restaurant",
            totalAmount: 250000,
            createdAt: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
            splitMethodRaw: "equal",
            group: group
        )
        expense1.id = UUID()
        context.insert(expense1)
        
        let expense2 = ExpenseEntity(
            title: "Movie Tickets",
            totalAmount: 120000,
            createdAt: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
            splitMethodRaw: "equal",
            group: group
        )
        expense2.id = UUID()
        context.insert(expense2)
        
        // Save context
        try context.save()
        
        return NavigationStack {
            EditGroupView(
                group: group,
                currentUserID: currentUserID,
                modelContext: context
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

#Preview("Group Page View") {
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
        
        // Create additional friends for "many members" state
        let friend6 = FriendEntity(userId: "user6", fullName: "John Dioe")
        friend6.id = UUID(uuidString: "00000000-0000-0000-0000-000000000007") ?? UUID()
        context.insert(friend6)
        
        let friend7 = FriendEntity(userId: "user7", fullName: "Andi Sandika")
        friend7.id = UUID(uuidString: "00000000-0000-0000-0000-000000000008") ?? UUID()
        context.insert(friend7)
        
        let friend8 = FriendEntity(userId: "user8", fullName: "Sari Yulia")
        friend8.id = UUID(uuidString: "00000000-0000-0000-0000-000000000009") ?? UUID()
        context.insert(friend8)
        
        // Create group with multiple members, payment due date, and expenses
        let group = GroupEntity(name: "Talangin")
        group.id = UUID(uuidString: "00000000-0000-0000-0000-000000000010") ?? UUID()
        group.paymentDueDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())
        // Add many members to show "many members" state
        group.members = [friend1, friend2, friend3, friend4, friend5, friend6, friend7, friend8]
        group.createdAt = Calendar.current.date(byAdding: .day, value: -30, to: Date())
        group.updatedAt = Date()
        context.insert(group)
        
        // Create multiple expenses for the group
        let expense1 = ExpenseEntity(
            title: "Dinner at Restaurant",
            totalAmount: 250000,
            createdAt: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
            splitMethodRaw: "equal",
            group: group
        )
        expense1.id = UUID()
        context.insert(expense1)
        
        let expense2 = ExpenseEntity(
            title: "Movie Tickets",
            totalAmount: 120000,
            createdAt: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
            splitMethodRaw: "equal",
            group: group
        )
        expense2.id = UUID()
        context.insert(expense2)
        
        let expense3 = ExpenseEntity(
            title: "Grocery Shopping",
            totalAmount: 350000,
            createdAt: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            splitMethodRaw: "equal",
            group: group
        )
        expense3.id = UUID()
        context.insert(expense3)
        
        // Save context
        try context.save()
        
        return NavigationStack {
            GroupPageView(
                group: group,
                currentUserID: currentUserID,
                modelContext: context
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

