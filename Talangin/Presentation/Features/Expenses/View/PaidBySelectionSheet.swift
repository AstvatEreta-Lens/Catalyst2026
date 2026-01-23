//
//  PaidBySelectionSheet.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 15/01/26.
//

import SwiftUI
import Combine

struct PaidBySelectionSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: PaidByViewModel
    
    let onConfirm: ([Payer]) -> Void
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        if !viewModel.allSelectedPayers.isEmpty {
                            selectedMembersCard
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }
                        
                        recentFriendsSection
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 100) // Space for footer
                }
                
                footerView
            }
            .navigationTitle("Paid By")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search name")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", action: dismiss.callAsFunction)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        onConfirm(viewModel.confirm())
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!viewModel.isTotalMatching)
                }
            }
            .animation(.default, value: viewModel.allSelectedPayers)
        }
    }
    
    private var selectedMembersCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(viewModel.allSelectedPayers) { payer in
                        VStack(spacing: 8) {
                            ZStack(alignment: .topTrailing) {
                                Text(payer.initials)
                                    .font(.custom(FontTokens.medium, size: 16))
                                    .foregroundColor(.blue)
                                    .frame(width: 56, height: 56)
                                    .background(Color(red: 0.9, green: 0.93, blue: 0.98))
                                    .clipShape(Circle())
                                
                                Button {
                                    viewModel.toggleSelection(for: payer)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.gray)
                                        .background(Circle().fill(Color.white))
                                        .font(.system(size: 20))
                                }
                                .offset(x: 8, y: -8)
                            }
                            
                            Text(payer.displayName)
                                .font(.custom(FontTokens.regular, size: 12))
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
    
    private var recentFriendsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Friends")
                .font(.custom(FontTokens.semiBold, size: 17))
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                // Add New Friend Row
                Button {
                    // Action to add friend
                } label: {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: 32, height: 32)
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.gray)
                        }
                        
                        Text("Add New Friend")
                            .font(.custom(FontTokens.regular, size: 17))
                            .foregroundColor(.gray.opacity(0.6))
                        
                        Spacer()
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal)
                }
                
                Divider()
                    .padding(.leading, 60)
                
                // Friends List
                ForEach(viewModel.filteredPayers) { payer in
                    payerRow(payer)
                    
                    if payer != viewModel.filteredPayers.last {
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

private extension PaidBySelectionSheet {
    
    func payerRow(_ payer: Payer) -> some View {
        HStack(spacing: 12) {
            Button {
                viewModel.toggleSelection(for: payer)
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(viewModel.isSelected(payer) ? Color(red: 0.2, green: 0.78, blue: 0.35) : Color.clear)
                        .frame(width: 24, height: 24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(viewModel.isSelected(payer) ? Color.clear : Color.gray.opacity(0.3), lineWidth: 2)
                        )
                    
                    if viewModel.isSelected(payer) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }

            Text(payer.displayName)
                .font(.custom(FontTokens.regular, size: 14))
                .foregroundColor(.black)
            
            if payer.isCurrentUser {
                Text("(Me)")
                    .font(.custom(FontTokens.regular, size: 14))
                    .foregroundColor(.gray.opacity(0.6))
            }
            
            Spacer()
            
            if viewModel.isSelected(payer) {
                HStack(spacing: 4) {
                    Text("Rp")
                        .font(.custom(FontTokens.regular, size: 12))
                        .foregroundColor(.secondary)
                    
                    TextField("0", text: Binding(
                        get: { viewModel.payerAmounts[payer.id] ?? "" },
                        set: { viewModel.updateAmount(for: payer, value: $0) }
                    ))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 90)
                    .font(.custom(FontTokens.medium, size: 16))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(uiColor: .secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal)
    }
}

private extension PaidBySelectionSheet {
    
    var footerView: some View {
        VStack(spacing: 0) {
            Divider()
            
            VStack(spacing: 12) {
                HStack {
                    Text("Total Paid")
                        .font(.custom(FontTokens.regular, size: 16))
                    Spacer()
                    Text(viewModel.currentTotalPaid.formatted(.currency(code: "IDR")))
                        .font(.custom(FontTokens.bold, size: 18))
                        .foregroundColor(
                            viewModel.isTotalMatching ? .black : .red
                        )
                }
                
                if viewModel.remainingAmount != 0 {
                    HStack {
                        Text("Remaining")
                            .font(.custom(FontTokens.regular, size: 14))
                        Spacer()
                        Text(viewModel.remainingAmount.formatted(.currency(code: "IDR")))
                            .font(.custom(FontTokens.medium, size: 14))
                            .foregroundColor(.black)
                    }
                }
            }
            .padding()
            .padding(.bottom, 24) // Extra padding for home indicator
        }
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.05), radius: 10, y: -5)
    }
}

#Preview {
    let mockPayers: [Payer] = [
        Payer(
            id: UUID(),
            displayName: "John",
            initials: "JD",
            isCurrentUser: true,
            amount:0
        ),
        Payer(
            id: UUID(),
            displayName: "Jane Smith",
            initials: "JS",
            isCurrentUser: false,
            amount:0
        ),
        Payer(
            id: UUID(),
            displayName: "Alex Tan",
            initials: "AT",
            isCurrentUser: false,
            amount:0
        ),
        Payer(
            id: UUID(),
            displayName: "Alex Jon",
            initials: "AT",
            isCurrentUser: false,
            amount:0
        ),
        
    ]
    
    let viewModel = PaidByViewModel(
        totalAmount: 150_000,
        participants: mockPayers
    )
    
    PaidBySelectionSheet(
        viewModel: viewModel,
        onConfirm: { payers in
            print("Confirmed payers:", payers)
        }
    )
}
