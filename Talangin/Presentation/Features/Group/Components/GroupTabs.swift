//
//  GroupTabs.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 25/01/26.
//

import SwiftUI

struct GroupSummaryTab: View {
    @ObservedObject var viewModel: GroupPageViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(viewModel.members) { member in
                let summary = viewModel.memberSummary(for: member.id)
                MemberSummaryCardView(
                    member: member,
                    currentUserID: viewModel.currentUserID,
                    youNeedToPay: summary.youNeedToPay,
                    waitingForPayment: summary.waitingForPayment
                )
            }
        }
    }
}

struct GroupExpensesTab: View {
    @ObservedObject var viewModel: GroupPageViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            if viewModel.groupedExpenses.isEmpty {
                Text("No Transactions Yet")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(viewModel.groupedExpenses, id: \.0) { date, expenses in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(date.formatted(date: .abbreviated, time: .omitted))
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 4)
                        
                        ForEach(expenses) { expense in
                            GroupExpenseCardView(expense: expense)
                        }
                    }
                }
            }
        }
    }
}

struct GroupMembersTab: View {
    @ObservedObject var viewModel: GroupPageViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("List Friends")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
                .padding(.horizontal, 4)
            
            VStack(spacing: 0) {
                // Add New Friend Button row
                Button {
                    // Action to add friend
                } label: {
                    HStack(spacing: 16) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(red: 60/255, green: 121/255, blue: 195/255))
                            .frame(width: 44, height: 44)
                        
                        Text("Add New Friend")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                
                Divider()
                    .padding(.leading, 76)
                
                // Members List
                ForEach(viewModel.members) { member in
                    HStack(spacing: 16) {
                        if let photoData = member.profilePhotoData, let uiImage = UIImage(data: photoData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 44, height: 44)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(uiColor: .secondarySystemBackground))
                                    .frame(width: 44, height: 44)
                                
                                Text(member.avatarInitials)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(Color(red: 0.17, green: 0.28, blue: 0.7))
                            }
                        }
                        
                        Text("\(member.fullName ?? "Unknown")\(member.id == viewModel.currentUserID ? " (Me)" : "")")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
    }
}
