//
//  HomeView.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 06/01/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var groups: [GroupEntity]
    @Query private var allExpenses: [ExpenseEntity]
    @Query private var allSettlements: [SettlementEntity]
    @Query private var allFriends: [FriendEntity]
    
    @State private var viewModel: HomeViewModel?
    
    // Using the same static ID as AddNewExpenseView for consistency in PoC
    private let currentUserID = UUID(uuidString: "00000000-0000-0000-0000-000000000001") ?? UUID()
    
    private var globalSummary: MemberSettlementSummary {
        // Find current user initials if available, or use "ME"
        let initials = "ME" 
        
        return SettlementCalculator.calculateSettlementSummary(
            for: currentUserID,
            memberName: "Me",
            memberInitials: initials,
            expenses: allExpenses,
            allMembers: allFriends,
            settlements: allSettlements
        )
    }
    
    private var totalNeedToPay: Double {
        globalSummary.totalNeedToPay
    }
    
    private var totalWaitingForPayment: Double {
        globalSummary.totalWaitingForPayment
    }
    
    var body: some View {
        NavigationStack{
            ScrollView{
                ZStack (alignment: .top){
                    // Background - Light green tint matching mockup
                    HomeHeaderView()
                    
                    VStack(alignment: .leading, spacing: 20) {
                        
                        SummaryCardView(
                            youNeedToPay: totalNeedToPay,
                            waitingForPayment: totalWaitingForPayment
                        )
                        // MARK: - Current Expenses Header
                        HStack {
                            Text("Current Expenses")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
//                            Button("See all") {
//                                // Action for See All
//                            }
//                            .font(.system(size: 16))
//                            .foregroundColor(.blue)
                        }
                        .padding(.horizontal, 8)
              
                        VStack(alignment: .leading, spacing: 12) {
                            Text("GROUPS")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)
                                .padding(.leading, 8 )

                            
                            if groups.isEmpty {
                                emptyStateView
                                    .frame(maxWidth: .infinity, minHeight: 200)
                            } else {
                                VStack(spacing: 0) {
                                    ForEach(Array(groups.enumerated()), id: \.element.id) { index, group in
                                        NavigationLink {
                                            GroupPageView(
                                                group: group,
                                                currentUserID: currentUserID,
                                                modelContext: modelContext
                                            )
                                        } label: {
                                            GroupCardView(
                                                group: group,
                                                currentUserID: currentUserID
                                            )
                                        }
                                        .buttonStyle(.plain)
                                        
                                        if index < groups.count - 1 {
                                            Divider()
                                                .padding(.leading, 76)
                                        }
                                    }
                                }
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
                            }
                        }
                        .padding(.bottom, 100)
             
                        if let viewModel = viewModel, let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .padding()
                        }
                    }
                    .padding(.top, 175)
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
            .ignoresSafeArea()
            .onAppear {
                print("🏠 HomeView onAppear - Found \(groups.count) groups")
                if viewModel == nil {
                    viewModel = HomeViewModel(modelContext: modelContext)
                }
            }
        }
        .background(Color(uiColor:.secondarySystemBackground))
    }
}

private var emptyStateView: some View {
    VStack(spacing: 16) {
        Image(systemName: "tray")
            .font(.system(size: 60))
            .foregroundStyle(.secondary)
        
        Text("No Groups Yet")
            .font(.Title2)
        
        Text("Create an expense to get started")
            .foregroundStyle(.secondary)
    }
    .padding()
}




#Preview {
    HomeView()
}
