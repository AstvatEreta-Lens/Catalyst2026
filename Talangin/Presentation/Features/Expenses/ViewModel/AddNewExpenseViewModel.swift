//
//  AddNewExpenseViewModel.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 17/01/26.
//

import SwiftUI
import SwiftData
import Combine

@MainActor
final class AddNewExpenseViewModel: ObservableObject {
    
    // MARK: - App State
    private var modelContext: ModelContext?
    
    // MARK: - Input State
    @Published var title: String = ""
    @Published var totalPrice: String = ""
    @Published var splitResult: SplitResult = .none
    @Published var expenseToEdit: ExpenseEntity?
    
    // MARK: - OCR
    @Published var items: [ExpenseItem] = []
    @Published var error: ReceiptScanError?
    
    // MARK: - Selection State
    @Published var selectedFriends: [FriendEntity] = []
    @Published var selectedGroups: [GroupEntity] = []
    @Published var selectedPayers: [Payer] = []
    
    private let preselectedGroup: GroupEntity?
    
    // MARK: - UI Flow State
    @Published var showBeneficiarySheet = false
    @Published var showSplitSchemeSheet = false
    @Published var showPaidBySheet = false
    @Published var isEditing: Bool = false
    
    // MARK: - Constants (Static for PoC)
    private static let currentUserID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    private static let currentUserName = "John Doe"
    
    // MARK: - Computed Properties
    
    private var currentUserFriend: FriendEntity {
        FriendEntity(
            id: Self.currentUserID,
            userId: "current_user",
            fullName: "\(Self.currentUserName) (Me)",
            email: nil,
            phoneNumber: nil,
            profilePhotoData: nil
        )
    }
    
    var selectedBeneficiaryAvatars: [(initials: String, type: String)] {
        var result: [(String, String)] = []
        result.append(contentsOf: selectedFriends.map { ($0.avatarInitials, "friend") })
        result.append(contentsOf: selectedGroups.map { ($0.avatarInitials, "group") })
        return result
    }
    
    var allBeneficiaries: [FriendEntity] {
        var uniqueFriends: [FriendEntity] = []
        var seenIDs: Set<UUID> = []
        
        // Add current user first
        uniqueFriends.append(currentUserFriend)
        seenIDs.insert(Self.currentUserID)
        
        // Add individuals
        for friend in selectedFriends {
            if let id = friend.id {
                if !seenIDs.contains(id) {
                    uniqueFriends.append(friend)
                    seenIDs.insert(id)
                }
            }
        }
        
        // Add group members
        for group in selectedGroups {
            for member in group.members ?? [] {
                if let id = member.id {
                    if !seenIDs.contains(id) {
                        uniqueFriends.append(member)
                        seenIDs.insert(id)
                    }
                }
            }
        }
        
        return uniqueFriends
    }
    
    var availablePayers: [Payer] {
        var result: [Payer] = []
        var seenIDs: Set<UUID> = []
        
        // Add current user first
        result.append(
            Payer(
                id: Self.currentUserID,
                name: Self.currentUserName,
                initials: currentUserFriend.avatarInitials,
                amount: 0,
                isCurrentUser: true
            )
        )
        seenIDs.insert(Self.currentUserID)
        
        // Add friends
        for friend in selectedFriends {
            guard let id = friend.id, !seenIDs.contains(id) else { continue }
            result.append(
                Payer(
                    id: id,
                    name: friend.fullName ?? "Unknown",
                    initials: friend.avatarInitials,
                    amount: 0,
                    isCurrentUser: false
                )
            )
            seenIDs.insert(id)
        }
        
        // Add group members
        for group in selectedGroups {
            for member in group.members ?? [] {
                guard let id = member.id, !seenIDs.contains(id) else { continue }
                result.append(
                    Payer(
                        id: id,
                        name: member.fullName ?? "Unknown",
                        initials: member.avatarInitials,
                        amount: 0,
                        isCurrentUser: false
                    )
                )
                seenIDs.insert(id)
            }
        }
        
        return result
    }
    
    var isFormValid: Bool {
        !title.isEmpty &&
        !totalPrice.isEmpty &&
        !selectedPayers.isEmpty &&
        !allBeneficiaries.isEmpty &&
        splitResult.method != .none
    }
    
    // MARK: - OCR Function
    func applyScannedItems(_ scannedItems: [ExpenseItem]) {
        let total = items.reduce(0) { $0 + $1.price }
        
        self.totalPrice = String(format: "%.0f", total)
        
        self.splitResult = .itemized(items: items)
        
        self.showSplitSchemeSheet = true
    }
    
    func scanOCR(image: UIImage) {
        reset()
        
        ObjectDetectionService.shared.detect(image: image) { [weak self] detections in
            guard let self else { return }
            
            guard let daftarBarang = detections.first(where: {
                $0.label == "daftar_barang"
            }) else {
                self.fail(.regionNotFound)
                return
            }
            
            guard let cropped = image.crop(to: daftarBarang.boundingBox) else {
                self.fail(.cropFailed)
                return
            }
            
            OCRService.recognizeText(from: cropped) { [weak self] text in
                guard let self else { return }
                
                Task { @MainActor in
                    if text.isEmpty {
                        self.fail(.ocrFailed)
                        return
                    }
                    
                    let parsedItems = ReceiptParserService.parse(from: text)
                    if parsedItems.isEmpty {
                        self.fail(.parsingFailed)
                        return
                    }
                    
                    self.items = parsedItems
                }
            }
        }
    }
    
    // MARK: - OCR Helpers
    private func reset() {
        items = []
        error = nil
    }
    
    private func fail(_ error: ReceiptScanError) {
        self.error = error
    }
    
    // MARK: - Initialization
    
    init(group: GroupEntity? = nil, expenseToEdit: ExpenseEntity? = nil) {
        self.preselectedGroup = group
        self.expenseToEdit = expenseToEdit
        
        if let group = group {
            self.selectedGroups = [group]
        }
        
        if let expense = expenseToEdit{
            self.isEditing = true
            loadExistingExpense(expense)
        }
    }
    
    func injectContext(_ context: ModelContext) {
        self.modelContext = context
        
        if isEditing, let expense = expenseToEdit {
            loadRelationalData(context: context, expense: expense)
        }
    }
    
    // MARK: - Actions
    
    func saveExpense(onSuccess: @escaping () -> Void) {
        guard isFormValid,
              let amount = Double(totalPrice),
              let context = modelContext else { return }
        
        let mappedPayers = selectedPayers.map { payer in
            PayerCodable(
                id: payer.id,
                displayName: payer.displayName,
                initials: payer.initials,
                isCurrentUser: payer.isCurrentUser,
                amount: payer.amount
            )
        }
        
        let mappedBeneficiaries = allBeneficiaries.map { friend in
            BeneficiaryCodable(
                id: friend.id ?? UUID(),
                fullName: friend.fullName ?? "Unknown",
                avatarInitials: friend.avatarInitials
            )
        }
        
        // Encode Data
        let payersData = try? JSONEncoder().encode(mappedPayers)
        let beneficiariesData = try? JSONEncoder().encode(mappedBeneficiaries)
        
        do {
            if isEditing, let existingExpense = expenseToEdit {
                // --- UPDATE EXISTING ---
                print("📝 Updating Expense: \(title)")
                
                existingExpense.title = title
                existingExpense.totalAmount = amount
                existingExpense.payersData = payersData
                existingExpense.beneficiariesData = beneficiariesData
                existingExpense.splitMethodRaw = splitResult.method.rawValue
                
                // Encode Split Details
                switch splitResult {
                case .equally:
                    existingExpense.splitDetailsData = nil
                case .unequally(let amounts):
                    existingExpense.splitDetailsData = try? JSONEncoder().encode(amounts)
                case .itemized(let items):
                    existingExpense.splitDetailsData = try? JSONEncoder().encode(items)
                case .none:
                    break
                }
                
                try context.save()
                print("✅ Update Berhasil!")
                onSuccess()
                
            } else {
                // --- CREATE NEW ---
                print("💾 Saving New Expense: \(title)")
                let repository = ExpenseRepository(modelContext: context)
                
                try repository.saveExpense(
                    title: title,
                    totalAmount: amount,
                    payers: selectedPayers,
                    beneficiaries: allBeneficiaries,
                    splitResult: splitResult,
                    targetGroup: preselectedGroup
                )
                print("✅ Simpan Berhasil!")
                onSuccess()
            }
        } catch {
            print("❌ Error saving/updating: \(error)")
        }
    }
    
    func updateBeneficiaries(friends: [FriendEntity], groups: [GroupEntity]) {
        self.selectedFriends = friends
        self.selectedGroups = groups
    }
    
    func updatePayers(_ payers: [Payer]) {
        self.selectedPayers = payers
    }
    
    // MARK: - Edit Action
    private func loadExistingExpense(_ expense: ExpenseEntity) {
        self.title = expense.title ?? ""
        self.totalPrice = String(format: "%.0f", expense.totalAmount ?? 0)
        
        self.selectedPayers = expense.payers.map { payerCodable in
            Payer(
                id: payerCodable.id,
                name: payerCodable.displayName,
                initials: payerCodable.initials,
                amount: payerCodable.amount,
                isCurrentUser: payerCodable.isCurrentUser
            )
        }
        
        if let methodRaw = expense.splitMethodRaw, let method = SplitMethod(rawValue: methodRaw) {
            switch method {
            case .equally:
                self.splitResult = .equally
                
            case .unequally:
                
                if let data = expense.splitDetailsData,
                   let amounts = try? JSONDecoder().decode([UUID: Double].self, from: data) {
                    self.splitResult = .unequally(amounts: amounts)
                }
                
            case .itemized:
                if let data = expense.splitDetailsData,
                   let items = try? JSONDecoder().decode([ExpenseItem].self, from: data) {
                    self.items = items
                    self.splitResult = .itemized(items: items)
                }
                
            case .none:
                self.splitResult = .none
            }
        }
        
        self.showSplitSchemeSheet = false
    }
    
    private func loadRelationalData(context: ModelContext, expense: ExpenseEntity) {
        // 1. Load Beneficiaries (Teman)
        // Kita harus mengambil FriendEntity asli dari database agar relasinya benar.
        // 'expense.beneficiaries' mengembalikan [BeneficiaryCodable] (struct), kita ambil ID-nya saja.
        let savedBeneficiaryIDs = expense.beneficiaries.map { $0.id }
        
        do {
            // Ambil semua teman dari database
            let descriptor = FetchDescriptor<FriendEntity>()
            let allFriendsInDB = try context.fetch(descriptor)
            
            // Filter: Ambil teman yang ID-nya ada di expense ini
            // DAN bukan Current User (karena Current User ditambahkan otomatis oleh `allBeneficiaries`)
            self.selectedFriends = allFriendsInDB.filter { friend in
                guard let id = friend.id else { return false }
                return savedBeneficiaryIDs.contains(id) && id != Self.currentUserID
            }
            
            print("✅ Loaded \(self.selectedFriends.count) friends for edit mode.")
            
        } catch {
            print("❌ Gagal meload FriendEntity: \(error)")
        }
        
        // 2. Load Groups (Jika expense terhubung ke group)
        // Jika Entity Anda punya properti `group` atau `targetGroup`
        /*
         if let group = expense.group { // Sesuaikan nama properti di Entity
         self.selectedGroups = [group]
         }
         */
    }
}
