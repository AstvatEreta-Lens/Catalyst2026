//
//  Payer.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 15/01/26.
//

import Foundation
import SwiftUI
import SwiftData
// MARK: - Payer Model

struct Payer: Identifiable, Equatable {

    let id: UUID
    let displayName: String
    let initials: String
    let isCurrentUser: Bool
    var amount: Double
}

extension Payer {
    
    init(entity: SplitParticipantEntity) {
        if let user = entity.user {
            self.id = entity.id ?? UUID()
            self.displayName = "\(user.fullName ?? "You") (Me)"
            self.initials = user.fullName
                .map {
                    let chars = $0
                        .components(separatedBy: " ")
                        .compactMap { $0.first }
                        .prefix(2)
                    return String(chars).uppercased()
                } ?? "ME"
            self.isCurrentUser = true
        } else if let friend = entity.friend {
            self.id = entity.id ?? UUID()
            self.displayName = friend.fullName ?? ""
            self.initials = friend.avatarInitials
            self.isCurrentUser = false
        } else {
            fatalError("Invalid SplitParticipantEntity")
        }

        self.amount = entity.amount ?? 0
    }
    
    // Simple initializer for creating Payers from friends
    init(
        id: UUID = UUID(),
        name: String,
        initials: String,
        amount: Double = 0,
        isCurrentUser: Bool = false
    ) {
        self.id = id
        self.displayName = isCurrentUser ? "\(name) (Me)" : name
        self.initials = initials
        self.amount = amount
        self.isCurrentUser = isCurrentUser
    }
}
