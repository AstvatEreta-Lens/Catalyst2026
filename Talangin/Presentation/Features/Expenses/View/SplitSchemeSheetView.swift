//
//  SplitSchemeSheetView.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 12/01/26.
//

import SwiftUI

struct SplitSchemeSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: SplitSchemeViewModel
    @Binding var splitResult: SplitResult
    
    init(totalAmount: Double, beneficiaries: [FriendEntity], splitResult: Binding<SplitResult>) {
        self._viewModel = StateObject(wrappedValue: SplitSchemeViewModel(
            totalAmount: totalAmount,
            beneficiaries: beneficiaries,
            initialResult: splitResult.wrappedValue
        ))
        self._splitResult = splitResult
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color(uiColor: .secondarySystemBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        SplitHeaderView(
                            title: viewModel.selectedMethod.rawValue,
                            description: viewModel.methodDescription ?? "",
                            imageName: viewModel.methodImageName
                        )
                        .padding(.top, 4)
                        
                        SplitMethodPicker(selection: $viewModel.selectedMethod)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("List Split")
                                    .font(.system(size: FontTokens.Callout.size, weight: FontTokens.bold))
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                if viewModel.selectedMethod == .itemized {
                                    Button(action: { viewModel.addNewItem() }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "plus.circle.fill")
                                            Text("Add")
                                        }
                                        .font(.system(size: 14, weight: FontTokens.bold))
                                        .foregroundColor(Color(red: 0.2, green: 0.7, blue: 0.3))
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            VStack(spacing: 0) {
                                switch viewModel.selectedMethod {
                                case .none:
                                    EmptyView()
                                case .equally:
                                    EquallySplitView(
                                        beneficiaries: viewModel.beneficiaries,
                                        equalShare: viewModel.equalShare
                                    )
                                case .unequally:
                                    UnequallySplitView(
                                        beneficiaries: viewModel.beneficiaries,
                                        manualAmounts: $viewModel.manualAmounts
                                    )
                                case .itemized:
                                    ItemizedSplitView(viewModel: viewModel)
                                }
                            }
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .padding(.horizontal)
                        }
                        
                        Spacer(minLength: 120) // Space for footer
                    }
                    .padding(.vertical)
                }
                
                SplitFooterView(
                    totalSplit: viewModel.currentTotalSplit ?? 0,
                    isMatching: viewModel.isTotalMatching
                )
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.blue)
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Split Type")
                        .font(.Headline)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        splitResult = viewModel.confirmResult()
                        dismiss()
                    }
                    .font(.Headline)
                    .foregroundColor(.blue)
                    .disabled(!viewModel.isTotalMatching && viewModel.selectedMethod != .equally)
                }
            }
        }
    }
}

// MARK: - Subviews

private struct SplitHeaderView: View {
    let title: String
    let description: String
    let imageName: String?
    
    var body: some View {
        VStack(spacing: 12) {
            if let imageName = imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 120)
            }
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.Title3)
                    .foregroundColor(.black)
                
                Text(description)
                    .font(.Footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}

private struct SplitMethodPicker: View {
    @Binding var selection: SplitMethod
    
    var body: some View {
        Picker("Split Method", selection: $selection) {
            ForEach(SplitMethod.allCases.filter { $0 != .none }) { method in
                Text(method.rawValue).tag(method)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }
}

private struct SplitFooterView: View {
    let totalSplit: Double
    let isMatching: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack {
                Text("Total Split")
                    .font(.system(size: FontTokens.Callout.size, weight: FontTokens.medium))
                Spacer()
                Text(totalSplit.formatted(.currency(code: "IDR")))
                    .font(.system(size: FontTokens.Callout.size, weight: FontTokens.bold))
                    .foregroundColor(isMatching ? .black : .red)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .background(Color.white)
        }
    }
}

private struct EquallySplitView: View {
    let beneficiaries: [FriendEntity]
    let equalShare: Double
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(beneficiaries) { friend in
                HStack(spacing: 12) {
                    InitialsAvatar(initials: friend.avatarInitials, size: 36)
                    
                    Text(friend.fullName ?? "Unknown")
                        .font(.system(size: FontTokens.Callout.size, weight: FontTokens.medium))
                    
                    Spacer()
                    
                    Text(equalShare.formatted(.currency(code: "IDR")))
                        .font(.system(size: FontTokens.Callout.size, weight: FontTokens.bold))
                        .foregroundColor(.black)
                }
                .padding(.horizontal)
                .padding(.vertical, 14)
                
                if friend.id != beneficiaries.last?.id {
                    Divider().padding(.horizontal)
                }
            }
        }
    }
}

private struct UnequallySplitView: View {
    let beneficiaries: [FriendEntity]
    @Binding var manualAmounts: [UUID: String]
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(beneficiaries) { friend in
                HStack(spacing: 12) {
                    InitialsAvatar(initials: friend.avatarInitials, size: 36)
                    
                    Text(friend.fullName ?? "Unknown")
                        .font(.system(size: FontTokens.Callout.size, weight: FontTokens.medium))
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Text("Rp")
                            .font(.system(size: 14, weight: FontTokens.regular))
                            .foregroundColor(.secondary)
                        
                        TextField("___________", text: Binding(
                            get: { friend.id.flatMap { manualAmounts[$0] } ?? "" },
                            set: { if let id = friend.id { manualAmounts[id] = $0 } }
                        ))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .font(.system(size: FontTokens.Callout.size, weight: FontTokens.bold))
                        .frame(width: 100)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 14)
                
                if friend.id != beneficiaries.last?.id {
                    Divider().padding(.horizontal)
                }
            }
        }
    }
}

private struct ItemizedSplitView: View {
    @ObservedObject var viewModel: SplitSchemeViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.items.isEmpty {
                Text("No items added yet.")
                    .font(.system(size: 14, weight: FontTokens.regular))
                    .foregroundColor(.secondary)
                    .padding(.vertical, 30)
                    .padding(.horizontal, 20)
                    .frame(width: 370, height: 270)
                
            } else {
                ForEach(Array(viewModel.items.enumerated()), id: \.offset) { index, item in
                    itemRow(index: index)
                    
                    if index != viewModel.items.count - 1 {
                        Divider().padding(.horizontal)
                    }
                }
            }
        }
    }
    
    private func itemRow(index: Int) -> some View {
        HStack(spacing: 8) {
            Button(action: { viewModel.deleteItem(viewModel.items[index]) }) {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.red)
                    .font(.system(size: 20))
            }
            
            TextField("Item", text: $viewModel.items[index].name)
                .font(.Callout)
            
            HStack(spacing: 4) {
                Text("Rp")
                    .font(.system(size: 14, weight: FontTokens.regular))
                    .foregroundColor(.black)
                    .fixedSize(horizontal: true, vertical: false)
                
                TextField("Price", value: $viewModel.items[index].price, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .font(.system(size: FontTokens.Callout.size, weight: FontTokens.bold))
                    .frame(width: 70)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            beneficiaryMenu(index: index)
        }
        .padding(.horizontal)
        .padding(.vertical, 14)
    }
    
    private func beneficiaryMenu(index: Int) -> some View {
        Menu {
            ForEach(viewModel.beneficiaries) { friend in
                Button(friend.fullName ?? "Unknown") {
                    viewModel.items[index].assignedBeneficiaryID = friend.id
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(viewModel.getBeneficiaryName(for: viewModel.items[index].assignedBeneficiaryID))
                    .lineLimit(1)
                    .font(.system(size: 14, weight: FontTokens.regular))
                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .bold))
            }
            .foregroundColor(.secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color(uiColor: .systemGray6))
            .cornerRadius(8)
        }
    }
}



