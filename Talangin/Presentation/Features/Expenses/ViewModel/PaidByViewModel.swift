//
//  PaidByViewModel.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 15/01/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class PaidByViewModel {

    // MARK: - Inputs
    let totalAmount: Double

    // MARK: - UI State
    private(set) var payers: [Payer]
    var payerAmounts: [UUID: String] = [:]
    var searchText = ""

    // MARK: - Init
    init(
        totalAmount: Double,
        participants: [Payer]
    ) {
        self.totalAmount = totalAmount
        self.payers = participants

        // hydrate textfield values
        for payer in payers {
            payerAmounts[payer.id] = payer.amount == 0 ? "" : String(format: "%.0f", payer.amount)
        }
    }

    var filteredPayers: [Payer] {
        if searchText.isEmpty {
            return payers
        } else {
            return payers.filter { $0.displayName.localizedCaseInsensitiveContains(searchText) }
        }
    }

    // MARK: - Derived State
    var currentTotalPaid: Double {
        payerAmounts.values
            .compactMap(Double.init)
            .reduce(0, +)
    }

    var remainingAmount: Double {
        totalAmount - currentTotalPaid
    }

    var isTotalMatching: Bool {
        abs(currentTotalPaid - totalAmount) < 1.0
    }
    
    var allSelectedPayers: [Payer] {
        payers.filter { isSelected($0) }
    }

    // MARK: - Actions
    func toggleSelection(for payer: Payer) {
        if isSelected(payer) {
            payerAmounts[payer.id] = nil
        } else {
            payerAmounts[payer.id] = ""
        }
    }

    func isSelected(_ payer: Payer) -> Bool {
        payerAmounts[payer.id] != nil
    }

    func updateAmount(for payer: Payer, value: String) {
        payerAmounts[payer.id] = value
    }

    func confirm() -> [Payer] {
        payers.map { payer in
            var updated = payer
            updated.amount = Double(payerAmounts[payer.id] ?? "0") ?? 0
            return updated
        }
        .filter { $0.amount > 0 }
    }
}
