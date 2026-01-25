//
//  ExpenseEntity.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 16/01/26.
//

import SwiftData
import Foundation

@Model
final class ExpenseEntity {
    
    var id: UUID?
    
    var title: String?
    var totalAmount: Double?
    var createdAt: Date?
    
    // Split method stored as string
    var splitMethodRaw: String?
    
    // Payers stored as JSON data
    @Attribute(.externalStorage)
    var payersData: Data?
    
    // Beneficiaries stored as JSON data
    @Attribute(.externalStorage)
    var beneficiariesData: Data?
    
    // Split details stored as JSON data
    @Attribute(.externalStorage)
    var splitDetailsData: Data?
    
    @Relationship(deleteRule: .cascade, inverse: \ExpenseItemEntity.expense)
    var items: [ExpenseItemEntity]? = []
    
    // Relationship to group
    @Relationship
    var group: GroupEntity?
    
    var payers: [PayerCodable] {
        guard let data = payersData else { return [] }
        return (try? JSONDecoder().decode([PayerCodable].self, from: data)) ?? []
    }
    
    var beneficiaries: [BeneficiaryCodable] {
        guard let data = beneficiariesData else { return [] }
        return (try? JSONDecoder().decode([BeneficiaryCodable].self, from: data)) ?? []
    }
    
    init(
        id: UUID = UUID(),
        title: String,
        totalAmount: Double,
        createdAt: Date = .now,
        splitMethodRaw: String,
        payersData: Data? = nil,
        beneficiariesData: Data? = nil,
        splitDetailsData: Data? = nil,
        group: GroupEntity? = nil
    ) {
        self.id = id
        self.title = title
        self.totalAmount = totalAmount
        self.createdAt = createdAt
        self.splitMethodRaw = splitMethodRaw
        self.payersData = payersData
        self.beneficiariesData = beneficiariesData
        self.splitDetailsData = splitDetailsData
        self.group = group
    }
}

// MARK: - Codable Helpers
struct PayerCodable: Codable {
    let id: UUID
    let displayName: String
    let initials: String
    let isCurrentUser: Bool
    let amount: Double
}

struct BeneficiaryCodable: Codable {
    let id: UUID
    let fullName: String
    let avatarInitials: String
}
