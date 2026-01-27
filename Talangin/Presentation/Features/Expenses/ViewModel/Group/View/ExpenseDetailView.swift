//
//  ExpenseDetailView.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 25/01/26.
//

import SwiftUI

struct ExpenseDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ExpenseDetailViewModel
    
    init(expense: ExpenseEntity) {
        _viewModel = StateObject(wrappedValue: ExpenseDetailViewModel(expense: expense))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
              ZStack(alignment: .topLeading) {
                  headerSection
                  VStack(spacing: 24) {
                      mainCard
                      splitWithSection
                      splitBySection
                  }
                  .padding(.top,160)
                  .padding(.horizontal)
                  .padding(.bottom, 30)
                }
                
            }
            .ignoresSafeArea()
            .zIndex(0)
        }
        .background( Color(uiColor: .secondarySystemBackground))
        .navigationBarHidden(true)
    }
    
    // MARK: - Subviews
    
    private var headerSection: some View {
        Color(red: 60/255, green: 121/255, blue: 195/255)
            .frame(height: 250)
            .overlay(
                VStack(spacing: 20) {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                Text("Groups")
                            }
                            .font(.body.weight(.semibold))
                            .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Button("Edit") {
                            // Edit logic - Could open AddNewExpenseView in edit mode
                        }
                        .font(.body.weight(.semibold))
                        .foregroundColor(.white)
                    }
                    .padding(.horizontal)
                    .padding(.top, 60)
                    
                    Text(viewModel.title)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    Spacer()
                }
            )
    }
    
    private var mainCard: some View {
        VStack(spacing: 0) {
            // Total Amount Section
            VStack(alignment: .leading, spacing: 8) {
                Text("TOTAL AMOUNT")
                    .font(.system(size: FontTokens.Caption1.size, weight: FontTokens.bold))
                    .foregroundColor(.secondary)
                
                HStack {
               
                    Text(viewModel.formatCurrency(viewModel.totalAmount))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Spacer()
   
                }
            }
            .padding(20)
            
            Divider()
                .padding(.horizontal, 20)
            
            // Paid By Section
            VStack(alignment: .leading, spacing: 16) {
                        Text("Paid By")
                            .font(.Headline)
                            .foregroundColor(.black)
                       
            
                    ForEach(viewModel.payers, id: \.id) { payer in
                        HStack(spacing: 12) {
                            InitialsAvatar(initials: payer.initials, size: 36)
                            
                            Text(payer.displayName)
                                .font(.system(size: 16, weight: .medium))
                            
                            Spacer()
                            
                            Text(viewModel.formatCurrency(payer.amount))
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                        }
                    
                }
            }
            .padding(16)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }

    
    
    private var splitWithSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Split With")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)
            
            HStack(spacing: 12) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.beneficiaries, id: \.id) { ben in
                            VStack(spacing: 8) {
                                InitialsAvatar(initials: ben.avatarInitials, size: 50)
                                Text(ben.fullName.components(separatedBy: " ").first ?? ben.fullName)
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding(20)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
    }
    
    private var splitBySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Split By")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)
            
            VStack(spacing: 0) {
                // Method Banner
                HStack(spacing: 8) {
                    Image(systemName: viewModel.splitMethod == .equally ? "person.2.fill" : "list.bullet")
                        .font(.system(size: 14))
                        .padding(8)
                        .background(Color(red: 0.56, green: 0.79, blue: 0.19).opacity(0.2))
                        .clipShape(Circle())
                        .foregroundColor(Color(red: 0.56, green: 0.79, blue: 0.19))
                    
                    Text(viewModel.splitMethod.rawValue)
                        .font(.system(size: 16, weight: .medium))
                    
                    Spacer()
                }
                .padding()
                .background(Color(red: 0.92, green: 0.96, blue: 0.87))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(12)
                
                Divider()
                    .padding(.horizontal)
                
                // Detailed Breakdown
                VStack(spacing: 0) {
                    if viewModel.splitMethod == .itemized {
                        ForEach(viewModel.items) { item in
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.name)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.primary)
                                    
                                    Text(viewModel.formatCurrency(item.price))
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                if let beneficiary = viewModel.beneficiaries.first(where: { $0.id == item.assignedBeneficiaryID }) {
                                    InitialsAvatar(initials: beneficiary.avatarInitials, size: 36)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                            
                            if item.id != viewModel.items.last?.id {
                                Divider().padding(.horizontal)
                            }
                        }
                    } else {
                        ForEach(viewModel.splitBreakdown, id: \.id) { row in
                            HStack(spacing: 12) {
                                InitialsAvatar(initials: row.initials, size: 36)
                                
                                Text(row.displayName)
                                    .font(.system(size: 16, weight: .medium))
                                
                                Spacer()
                                
                                Text(viewModel.formatCurrency(row.amount))
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                            
                            if row.id != viewModel.splitBreakdown.last?.id {
                                Divider().padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.bottom, 8)
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
    }
}

private extension View {
    func cardStyle() -> some View {
        self
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.05), radius: 10)
            .padding(.horizontal, 0)
    }
}

import SwiftData

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: ExpenseEntity.self, configurations: config)
    
    let payers = [
        PayerCodable(id: UUID(), displayName: "John Doe (Me)", initials: "JD", isCurrentUser: true, amount: 30000),
        PayerCodable(id: UUID(), displayName: "Andi Sandika", initials: "AS", isCurrentUser: false, amount: 20000),
        PayerCodable(id: UUID(), displayName: "Sania Filma", initials: "SF", isCurrentUser: false, amount: 20000)
    ]
    let payersData = try? JSONEncoder().encode(payers)
    
    let beneficiaries = [
        BeneficiaryCodable(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!, fullName: "John Doe", avatarInitials: "JD"),
        BeneficiaryCodable(id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!, fullName: "Andi Sandika", avatarInitials: "AS"),
        BeneficiaryCodable(id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!, fullName: "Imroatus", avatarInitials: "IM"),
        BeneficiaryCodable(id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!, fullName: "Chikmah", avatarInitials: "CH"),
        BeneficiaryCodable(id: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!, fullName: "Sari Yulia", avatarInitials: "SY")
    ]
    let beneficiariesData = try? JSONEncoder().encode(beneficiaries)
    
    let items = [
        ExpenseItem(name: "Cilok daging", price: 3000, assignedBeneficiaryID: beneficiaries[0].id),
        ExpenseItem(name: "Cilok Babi", price: 5000, assignedBeneficiaryID: beneficiaries[1].id),
        ExpenseItem(name: "Cilok Russ", price: 4000, assignedBeneficiaryID: beneficiaries[2].id)
    ]
    let itemsData = try? JSONEncoder().encode(items)
    
    let expense = ExpenseEntity(
        title: "Ngebakso",
        totalAmount: 12000,
        splitMethodRaw: "Itemized",
        payersData: payersData,
        beneficiariesData: beneficiariesData,
        splitDetailsData: itemsData
    )
    
    return NavigationStack {
        ExpenseDetailView(expense: expense)
            .modelContainer(container)
    }
}
