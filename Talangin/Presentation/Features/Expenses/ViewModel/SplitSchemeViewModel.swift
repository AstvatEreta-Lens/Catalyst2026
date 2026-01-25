
//
//  SplitSchemeViewModel.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 13/01/26.
//

import SwiftUI
import Observation
import Foundation
import Combine

@MainActor
final class SplitSchemeViewModel: ObservableObject {

    // MARK: - Inputs
    let totalAmount: Double
    let beneficiaries: [FriendEntity]

    // MARK: - UI State
    @Published var selectedMethod: SplitMethod

    // Unequally
    @Published var manualAmounts: [UUID: String] = [:]

    // Itemized
    @Published var items: [ExpenseItem] = []

    // MARK: - Init
    init(
        totalAmount: Double,
        beneficiaries: [FriendEntity],
        initialResult: SplitResult
    ) {
        self.totalAmount = totalAmount
        self.beneficiaries = beneficiaries
        self.selectedMethod = initialResult.method

        hydrate(from: initialResult)
    }

    // MARK: - Derived State
    var methodDescription: String?{
        switch selectedMethod {
        case .none:
            return nil
        case .equally:
            return "Automatically divide the total cost equally among everyone."
        case .unequally:
            return "Manually assign specific amounts."
        case .itemized:
            return "Assign specific items from the receipt to the people who ordered them."
        }
    }

    var methodImageName: String? {
        switch selectedMethod {
        case .equally:
            return "equally"
        case .unequally:
            return "manually"
        case .itemized:
            return "itemized"
        default:
            return nil
        }
    }

    var currentTotalSplit: Double? {
        switch selectedMethod {
        case .none:
            return nil
        case .equally:
            return totalAmount
        case .unequally:
            return manualAmounts.values.compactMap(Double.init).reduce(0, +)
        case .itemized:
            return items.reduce(0) { $0 + $1.price }
        }
    }

    var isTotalMatching: Bool {
        guard let currentTotalSplit else { return false }
          return abs(currentTotalSplit - totalAmount) < 1.0
    }

    var equalShare: Double {
        beneficiaries.isEmpty ? 0 : totalAmount / Double(beneficiaries.count)
    }

    // MARK: - Itemized helpers
//    var isItemValid: Bool {
//        !newItemName.isEmpty &&
//        Double(newItemPrice) != nil &&
//        newItemBeneficiary != nil
//    }

    // MARK: - Actions
    func confirmResult() -> SplitResult {
        switch selectedMethod {
        case .none:
            return .equally
        case .equally:
            return .equally
        case .unequally:
            let amounts = manualAmounts.compactMapValues(Double.init)
            return .unequally(amounts: amounts)

        case .itemized:
            return .itemized(items: items)
        }
    }

    func addNewItem() {
        items.append(ExpenseItem(name: "", price: 0))
    }

    func deleteItem(_ item: ExpenseItem) {
        items.removeAll { $0.id == item.id }
    }

    func getBeneficiaryName(for id: UUID?) -> String {
        guard let id else { return "Paid by" }
        return beneficiaries.first(where: { $0.id == id })?.fullName ?? "Paid by"
    }

    // MARK: - Private
    private func hydrate(from result: SplitResult) {
        switch result {
        case .unequally(let amounts):
            manualAmounts = amounts.mapValues { String(format: "%.0f", $0) }
        case .itemized(let items):
            self.items = items
        default:
            break
        }
    }
}
