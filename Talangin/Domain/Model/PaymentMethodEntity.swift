//
//  PaymentMethodEntity.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 07/01/26.
//


import SwiftData
import Foundation

@Model
final class PaymentMethodEntity {

    // MARK: - Identity
    var id: UUID?

    // MARK: - Data
    var providerName: String
    var destination: String
    var holderName: String
    var isDefault: Bool

    // MARK: - Relationship
    @Relationship
    var user: UserEntity?

    // MARK: - Metadata
    var createdAt: Date?

    init(
        providerName: String,
        destination: String,
        holderName: String = "",
        isDefault: Bool = false,
        user: UserEntity
    ) {
        self.id = UUID()
        self.providerName = providerName
        self.destination = destination
        self.holderName = holderName
        self.isDefault = isDefault
        self.user = user
        self.createdAt = .now
    }
}
