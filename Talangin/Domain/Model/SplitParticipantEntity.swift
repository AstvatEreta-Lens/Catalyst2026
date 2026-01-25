//
//  SplitParticipantEntity.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 16/01/26.
//


import SwiftData
import Foundation


@Model
final class SplitParticipantEntity {

    var id: UUID?
    // siapa orangnya
    @Relationship
    var user: UserEntity?

    @Relationship
    var friend: FriendEntity?

    // context split
    var amount: Double?

    var createdAt: Date?

    init(
        id: UUID = UUID(),
        user: UserEntity? = nil,
        friend: FriendEntity? = nil,
        amount: Double = 0
    ) {
        self.id = id
        self.user = user
        self.friend = friend
        self.amount = amount
        self.createdAt = .now
    }
}
