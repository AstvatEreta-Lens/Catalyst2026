//
//  ExpenseItemEntity.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 17/01/26.
//

import SwiftData
import Foundation

@Model
final class ExpenseItemEntity {
    var id: UUID?
    var name: String?
    var price: Double?
    var assignedBeneficiaryID: UUID?
    
    @Relationship
    var expense: ExpenseEntity?
    
    init(
        id: UUID = UUID(),
        name: String,
        price: Double,
        assignedBeneficiaryID: UUID? = nil,
        expense: ExpenseEntity? = nil
    ) {
        self.id = id
        self.name = name
        self.price = price
        self.assignedBeneficiaryID = assignedBeneficiaryID
        self.expense = expense
    }
}
