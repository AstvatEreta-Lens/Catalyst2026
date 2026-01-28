//
//  SettlementEntity.swift
//  Talangin
//
//  Created by System on 28/01/26.
//

import Foundation
import SwiftData

@Model
final class SettlementEntity {
    var id: UUID
    var fromMemberID: UUID
    var toMemberID: UUID
    var amount: Double
    var date: Date
    var attachmentData: Data?
    var paymentMethod: String
    
    // IDs of expenses that were settled by this transaction
    // Stored as JSON data for simplicity in SwiftData
    var settledExpenseIDsData: Data?
    
    var settledExpenseIDs: [UUID] {
        get {
            guard let data = settledExpenseIDsData else { return [] }
            return (try? JSONDecoder().decode([UUID].self, from: data)) ?? []
        }
        set {
            settledExpenseIDsData = try? JSONEncoder().encode(newValue)
        }
    }
    
    init(
        id: UUID = UUID(),
        fromMemberID: UUID,
        toMemberID: UUID,
        amount: Double,
        date: Date = .now,
        attachmentData: Data? = nil,
        paymentMethod: String = "Bank Transfer",
        settledExpenseIDs: [UUID] = []
    ) {
        self.id = id
        self.fromMemberID = fromMemberID
        self.toMemberID = toMemberID
        self.amount = amount
        self.date = date
        self.attachmentData = attachmentData
        self.paymentMethod = paymentMethod
        self.settledExpenseIDsData = try? JSONEncoder().encode(settledExpenseIDs)
    }
}
