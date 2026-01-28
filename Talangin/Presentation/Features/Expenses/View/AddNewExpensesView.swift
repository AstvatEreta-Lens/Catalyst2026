//
//  AddNewExpensesView.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 11/01/26.
//
import SwiftUI

struct AddNewExpenseView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: AddNewExpenseViewModel
    
    @State private var showImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    @State private var inputImage: UIImage?
    
    init(group: GroupEntity? = nil, expenseToEdit: ExpenseEntity? = nil) {
        _viewModel = StateObject(wrappedValue: AddNewExpenseViewModel(group: group, expenseToEdit: expenseToEdit))
    }
    
    var body: some View {
        NavigationStack {
                ScrollView{
                    ZStack(alignment: .top) {
                        headerSection
                      
                        VStack(spacing: 24) {
                            mainCard
                            splitWithSection
                            splitTypeSection
                        }
                        .padding(.top, 160)
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
            .ignoresSafeArea()
            .navigationBarHidden(true)
            .onAppear {
                viewModel.injectContext(modelContext)
            }
            .sheet(isPresented: $viewModel.showBeneficiarySheet) {
                BeneficiarySelectionSheet { friends, groups in
                    viewModel.updateBeneficiaries(friends: friends, groups: groups)
                }
            }
            .sheet(isPresented: $viewModel.showSplitSchemeSheet){
                SplitSchemeSheetView(
                    totalAmount: Double(viewModel.totalPrice) ?? 0,
                    beneficiaries: viewModel.allBeneficiaries,
                    splitResult: $viewModel.splitResult
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $viewModel.showPaidBySheet) {
                PaidBySelectionSheet(
                    viewModel: PaidByViewModel(
                        totalAmount: Double(viewModel.totalPrice) ?? 0,
                        participants: viewModel.availablePayers
                    ),
                    onConfirm: { payers in
                        viewModel.updatePayers(payers)
                    }
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
        }
        .background(Color(uiColor: .secondarySystemBackground))
    }
    
    private var headerSection: some View {
        Color(red: 60/255, green: 121/255, blue: 195/255)
            .frame(height: 282)
            .overlay(
                VStack(spacing: 20) {
                    // Custom Navigation Bar
                    
                    HStack {
                        Button("Cancel") {
                            dismiss()
                        }
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(viewModel.isEditing ? "Save" : "Create") {
                            viewModel.saveExpense {
                                dismiss()
                            }
                        }
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .disabled(!viewModel.isFormValid)
                        .opacity(viewModel.isFormValid ? 1.0 : 0.6)
                    }
                    .padding(.horizontal)
                    .padding(.top, 50)
                    
                    // Title Field
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("", text: $viewModel.title, prompt: Text("Expense Name").foregroundColor(.white.opacity(0.7)))
                            .font(.system(size: FontTokens.Title1.size, weight: FontTokens.medium))
                            .foregroundColor(.white)
                        
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    Spacer()
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 0))
    }
    
    private var mainCard: some View {
        VStack(spacing: 0) {
            // Total Amount Section
            VStack(alignment: .leading, spacing: 8) {
                Text("TOTAL AMOUNT")
                    .font(.system(size: FontTokens.Caption1.size, weight: FontTokens.bold))
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("Rp")
                        .font(.system(size: 24, weight: FontTokens.bold))
                        .foregroundColor(.black)
                    TextField("0", text: $viewModel.totalPrice)
                        .font(.system(size: 24, weight: FontTokens.bold))
                        .keyboardType(.numberPad)
                    
                    Spacer()
                    if viewModel.expenseToEdit == nil {
                        Menu {
                            Button {
                                self.sourceType = .camera
                                self.showImagePicker = true
                            } label: {
                                Label("Take a Photo", systemImage: "camera")
                            }
                            
                            Button {
                                inputImage = nil
                                self.sourceType = .photoLibrary
                                self.showImagePicker = true
                            } label: {
                                Label("Choose from Gallery", systemImage: "photo.on.rectangle")
                            }
                        } label: {
                            Image(systemName: "document.viewfinder")
                                .renderingMode(.template)
                                .font(.system(size: 24))
                                .foregroundColor(.blue)
                        }
                    }
                }
                .sheet(isPresented: $showImagePicker) {
                    CameraView(image: $inputImage, sourceType: sourceType).id(sourceType)
                }
                .onChange(of: inputImage) {_, newImage in
                    if let image = newImage {
                        viewModel.scanOCR(image: image)
                    }
                }
                .onReceive(viewModel.$items) { detectedItems in
                    if !detectedItems.isEmpty && !viewModel.isEditing{
                        DispatchQueue.main.async {
                            viewModel.applyScannedItems(detectedItems)
                        }
                        
                        inputImage = nil
                    }
                }
                .alert(
                    "Scan Gagal",
                    isPresented: Binding(
                        get: { viewModel.error != nil },
                        set: { _ in viewModel.error = nil }
                    )
                ) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(viewModel.error?.localizedDescription ?? "")
                }
            }
            .padding(20)
            
            Divider()
                .padding(.horizontal, 20)
            
            // Paid By Section
            VStack(alignment: .leading, spacing: 16) {
                Button(action: { viewModel.showPaidBySheet = true }) {
                    HStack{
                        Text("Paid By")
                            .font(.Headline)
                            .foregroundColor(.black)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    
                }
                HStack(spacing: 12) {
                    if let firstPayer = viewModel.selectedPayers.first {
                        InitialsAvatar(initials: firstPayer.initials, size: 36)
                        
                        
                        Text(firstPayer.displayName)
                            .font(.system(size: FontTokens.Callout.size, weight: FontTokens.medium))
                            .foregroundColor(.black)
                        
                        Spacer()
                        if firstPayer.amount > 0 {
                            Text(firstPayer.amount.formatted(.currency(code: "IDR")))
                                .font(.Callout)
                                .foregroundColor(.secondary)
                        }
                        
                    } else {
                        Text("Select Payer")
                            .font(.Callout)
                            .foregroundColor(.secondary)
                    }
                    
                }
            }
            .padding(20)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    private var splitWithSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Split With")
                .font(.system(size: FontTokens.Subheadline.size, weight: FontTokens.bold))
                .foregroundColor(.black)
            
            Button(action: { viewModel.showBeneficiarySheet = true }) {
                HStack {
                    if viewModel.selectedBeneficiaryAvatars.isEmpty {
                        Text("Select People")
                            .foregroundColor(.secondary)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(viewModel.allBeneficiaries, id: \.id) { beneficiary in
                                    VStack(spacing: 8) {
                                        InitialsAvatar(initials: beneficiary.avatarInitials, size: 50)
                                        Text(beneficiary.fullName?.components(separatedBy: " ").first ?? "Unknown")
                                            .font(.footnote)
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                    }
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
            }
        }
    }
    
    private var splitTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Split Type")
                .font(.system(size: FontTokens.Subheadline.size, weight: FontTokens.bold))
                .foregroundColor(.black)
            
            VStack(spacing: 0) {
                Button(action: { viewModel.showSplitSchemeSheet = true }) {
                    HStack {
                        contentForSplitMethod
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(height: 60)
                    .background(viewModel.splitResult.method == .none ? Color.white : Color(red: 0.92, green: 0.96, blue: 0.87))
                }
                
                if viewModel.splitResult != .none {
                    Divider()
                        .padding(.horizontal)
                    
                    splitResultPreview
                        .padding(.bottom, 8)
                }
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
    }
    
    @ViewBuilder
    private var splitResultPreview: some View {
        switch viewModel.splitResult {
        case .none:
            EmptyView()
        case .equally:
            equalSplitPreview
        case .unequally(let amounts):
            unequallySplitPreview(amounts: amounts)
        case .itemized(let items):
            itemizedSplitPreview(items: items)
        }
    }
    
    private var equalSplitPreview: some View {
        let beneficiaries = viewModel.allBeneficiaries
        let totalAmount = Double(viewModel.totalPrice) ?? 0
        let share = beneficiaries.isEmpty ? 0 : totalAmount / Double(beneficiaries.count)
        
        return VStack(spacing: 0) {
            ForEach(beneficiaries) { beneficiary in
                beneficiaryRow(name: beneficiary.fullName ?? "Unknown", initials: beneficiary.avatarInitials, amount: share)
            }
        }
    }
    
    private func unequallySplitPreview(amounts: [UUID: Double]) -> some View {
        VStack(spacing: 0) {
            ForEach(viewModel.allBeneficiaries) { beneficiary in
                let amount = amounts[beneficiary.id ?? UUID()] ?? 0
                beneficiaryRow(name: beneficiary.fullName ?? "Unknown", initials: beneficiary.avatarInitials, amount: amount)
            }
        }
    }
    
    private func itemizedSplitPreview(items: [ExpenseItem]) -> some View {
        VStack(spacing: 0) {
            ForEach(items) { item in
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.name)
                            .font(.system(size: FontTokens.Callout.size, weight: FontTokens.medium))
                            .foregroundColor(.black)
                        Text(item.price.formatted(.currency(code: "IDR")))
                            .font(.system(size: FontTokens.Subheadline.size, weight: FontTokens.regular))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if let benID = item.assignedBeneficiaryID,
                       let beneficiary = viewModel.allBeneficiaries.first(where: { $0.id == benID }) {
                        InitialsAvatar(initials: beneficiary.avatarInitials, size: 36)
                    } else {
                        Image(systemName: "person.fill.questionmark")
                            .font(.system(size: 18))
                            .foregroundColor(.secondary)
                            .frame(width: 36, height: 36)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                
                if item.id != items.last?.id {
                    Divider().padding(.horizontal)
                }
            }
        }
    }
    
    private func beneficiaryRow(name: String, initials: String, amount: Double) -> some View {
        HStack(spacing: 12) {
            InitialsAvatar(initials: initials, size: 36)
            
            Text(name)
                .font(.system(size: FontTokens.Callout.size, weight: FontTokens.medium))
                .foregroundColor(.black)
            
            Spacer()
            
            Text(amount.formatted(.currency(code: "IDR")))
                .font(.system(size: FontTokens.Callout.size, weight: FontTokens.bold))
                .foregroundColor(.black)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
    
    @ViewBuilder
    private var contentForSplitMethod: some View {
        let method = viewModel.splitResult.method
        
        if method == .none {
            Text("Choose Split Method")
                .font(.Callout)
                .foregroundColor(.secondary)
        } else {
            let iconName: String = {
                switch method {
                case .equally:   return "arrow.trianglehead.branch"
                case .unequally: return "person.2.fill"
                case .itemized:  return "list.bullet"
                case .none:      return ""
                }
            }()
            
            let title: String = {
                switch method {
                case .equally:   return "Equal"
                case .unequally: return "Unequally"
                case .itemized:  return "Itemized"
                case .none:      return ""
                }
            }()
            
            let themeGreen = Color(red: 0.56, green: 0.79, blue: 0.19)
            
            HStack {
                Image(systemName: iconName)
                    .font(.system(size: 14))
                    .padding(8)
                    .background(themeGreen.opacity(0.2))
                    .clipShape(Circle())
                    .foregroundColor(themeGreen)
                
                Text(title)
                    .font(.system(size: FontTokens.Callout.size, weight: FontTokens.medium))
                    .foregroundColor(.black)
            }
        }
    }
}

#Preview {
    AddNewExpenseView()
}

