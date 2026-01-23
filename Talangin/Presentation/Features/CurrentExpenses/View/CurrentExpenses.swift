//
//  CurrentExpenses.swift
//  OCR-Practice
//
//  Created by Ali Jazzy Rasyid on 20/01/26.
//

import SwiftUI
import SwiftData

struct CurrentExpenses: View {
    @State private var searchText = ""
    @State private var selectedSegment: ExpenseSegment = .friends
    
    // MARK: - SwiftData Queries
    
    @Query(sort: \FriendEntity.fullName) private var allFriends: [FriendEntity]
    @Query(sort: \GroupEntity.name) private var allGroups: [GroupEntity]
    
    // MARK: - Filter Logic
    
    var filteredFriends: [FriendEntity] {
        if searchText.isEmpty {
            return allFriends
        } else {
            return allFriends.filter { friend in
                (friend.fullName ?? "").localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var filteredGroups: [GroupEntity] {
        if searchText.isEmpty {
            return allGroups
        } else {
            return allGroups.filter { group in
                (group.name ?? "").localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    // MARK: - Section Picker
                    Section {
                    } header: {
                        Picker("Picker", selection: $selectedSegment) {
                            ForEach(ExpenseSegment.allCases, id: \.self) {
                                Text($0.rawValue)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .listRowInsets(EdgeInsets())
                    
                    // MARK: - Section Data List
                    Section {
                        if selectedSegment == .friends {
                            // --- TAMPILKAN DAFTAR TEMAN ---
                            if filteredFriends.isEmpty {
                                ContentUnavailableView("No Friends", systemImage: "person.slash")
                            } else {
                                ForEach(filteredFriends) { friend in
                                    let dummyAmount = 15000.0
                                    let status = "You Owe"
                                    
                                    NavigationLink(destination: PayNowView()) {
                                        ExpensesList(
                                            item: friend,
                                            subtitle: status,
                                            amount: dummyAmount
                                        )
                                    }
                                }
                            }
                        } else {
                            if filteredGroups.isEmpty {
                                ContentUnavailableView("No Groups", systemImage: "person.slash")
                            } else {
                                ForEach(filteredGroups) { group in
                                    let totalExpense = 250000.0
                                    let memberInfo = "\(group.members?.count ?? 0) Anggota"
                                    
                                    NavigationLink(destination: PayNowView()) {
                                        ExpensesList(
                                            item: group,
                                            subtitle: memberInfo,
                                            amount: totalExpense
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
                .listSectionSpacing(24)
            }
            .navigationTitle("Recent Activities")
            
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .automatic),
                prompt: "Find name..."
            )
        }
    }
}

// Helper Enum
enum ExpenseSegment: String, CaseIterable {
    case friends = "Friends"
    case groups = "Groups"
}


