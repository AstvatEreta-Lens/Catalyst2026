//
//  GroupPageView.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 16/01/26.
//

import SwiftUI
import SwiftData

struct GroupPageView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: GroupPageViewModel
    @State private var showShareSheet = false
    @State private var invoiceFileURL: URL?
    @State private var isGeneratingInvoice = false
    
    init(group: GroupEntity, currentUserID: UUID, modelContext: ModelContext) {
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
        .overlay {
            if isGeneratingInvoice {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                        
                        Text("Preparing Invoice...")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding(30)
                    .background(Color(.systemGray6).opacity(0.8))
                    .cornerRadius(20)
                }
            }
        }
        .background {
            if let url = invoiceFileURL {
                ShareSheetPresenter(isPresented: $showShareSheet, items: [url])
            }
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
                    isGeneratingInvoice = true
                    Task {
                        // 1. Wait for menu animation to finish
                        try? await Task.sleep(nanoseconds: 500_000_000)
                        
                        // 2. Generate Invoice PDF
                        let url = await InvoiceGenerator.generateInvoicePDF(
                            group: viewModel.group,
                            members: viewModel.members,
                            expenses: viewModel.expenses
                        )
                        
                        await MainActor.run {
                            isGeneratingInvoice = false
                            if let url = url {
                                invoiceFileURL = url
                                showShareSheet = true
                            }
                        }
                    }
                } label: {
                    Label("Share Invoice", systemImage: "doc.text")
                }
                .disabled(isGeneratingInvoice)
                
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
