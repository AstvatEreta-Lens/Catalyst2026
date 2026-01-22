//
//  GroupDetailView.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 16/01/26.
//

import SwiftUI
import SwiftData

struct GroupDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let group: GroupEntity
    let currentUserID: UUID
    
    @State private var selectedTab = 0
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header section
                headerSection
                
                // Content section
                VStack(spacing: 20) {
                    // Segmented Tabs
                    customSegmentedControl
                    
                    if selectedTab == 0 {
                        summaryTab
                    } else if selectedTab == 1 {
                        transactionsTab
                    } else {
                        membersTab
                    }
                }
                .padding()
                .background(Color(uiColor: .systemGroupedBackground))
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
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
            
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.fill") // Placeholder for user avatar
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.white)
                    
                    Menu {
                        Button(role: .destructive) {
                            showDeleteConfirmation = true
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
        }
        .alert("Delete Group", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteGroup()
            }
        } message: {
            Text("Are you sure you want to delete '\(group.name ?? "this group")'? This action cannot be undone.")
        }
    }
    
    private func deleteGroup() {
        let repository = GroupRepository(modelContext: modelContext)
        do {
            try repository.deleteGroup(group)
            dismiss()
        } catch {
            print("Error deleting group: \(error)")
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        ZStack {
            Color("#3C79C3")
            VStack(spacing: 16) {
                Spacer(minLength: 80)
                
                // Group Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color(uiColor: .systemGray6).opacity(0.3))
                        .overlay(
                            RoundedRectangle(cornerRadius: 31.5)
                                .fill(Color.white)
                                .padding(10)
                        )
                        .frame(width: 120, height: 120)
                    
                    Text(group.avatarInitials)
                        .font(.system(size: 40, weight: .bold))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(group.name ?? "Untitled Group")
                        .font(.title.bold())
                        .foregroundColor(.black)
                    
                    HStack(spacing: 20) {
                        Text("\(group.memberCount) Members")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.caption)
                            Text("No Date")
                                .font(.caption)
                        }
                        .foregroundColor(.gray)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }
    
    // MARK: - Tabs
    private var customSegmentedControl: some View {
        HStack(spacing: 0) {
            tabItem(title: "Summary", index: 0)
            tabItem(title: "Transactions", index: 1)
            tabItem(title: "Member", index: 2)
        }
        .background(Color(uiColor: .systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 4)
    }
    
    private func tabItem(title: String, index: Int) -> some View {
        Button {
            selectedTab = index
        } label: {
            Text(title)
                .font(.subheadline)
                .fontWeight(selectedTab == index ? .semibold : .regular)
                .foregroundColor(selectedTab == index ? .black : .secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    selectedTab == index ? Color.white : Color.clear
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(2)
        }
    }
    
    // MARK: - Tab Views
    private var summaryTab: some View {
        VStack(spacing: 16) {
            ForEach(group.members ?? []) { member in
                memberSummaryCard(member: member)
            }
        }
    }
    
    private var transactionsTab: some View {
        VStack(spacing: 16) {
            Text("No Transactions Yet")
                .foregroundColor(.secondary)
                .padding()
        }
    }
    
    private var membersTab: some View {
        VStack(spacing: 16) {
            ForEach(group.members ?? []) { member in
                HStack(spacing: 12) {
                    InitialsAvatar(initials: member.avatarInitials, size: 40)
                    Text(member.fullName ?? "Unknown")
                    Spacer()
                }
                .padding()
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
    // MARK: - Member Card
    private func memberSummaryCard(member: FriendEntity) -> some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color(uiColor: .systemGray6))
                        .frame(width: 40, height: 40)
                    Text(member.avatarInitials)
                        .font(.caption.bold())
                }
                
                Text("\(member.fullName ?? "Unknown")\(member.id == currentUserID ? " (Me)" : "")")
                    .font(.headline)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("You Need To Pay")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.right")
                            .foregroundColor(.red)
                        Text("Rp 45.000")
                            .fontWeight(.bold)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Waiting For Payment")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.down.left")
                            .foregroundColor(.green)
                        Text("Rp 45.000")
                            .fontWeight(.bold)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
}


