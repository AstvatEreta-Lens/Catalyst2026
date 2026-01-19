//
//  TalanginApp.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 01/01/26.
//
//  Main app entry point with SwiftData model container configuration.
//  Updated: Added ContactEntity, ContactPaymentMethod, and GroupEntity models.
//

import SwiftUI
import SwiftData

@main
struct TalanginApp: App {
    @StateObject private var authState = AppAuthState()

    var body: some Scene {
        WindowGroup {
            AuthGateView()
                .environmentObject(authState)
        }
        .modelContainer(for: [
            Item.self,
            UserEntity.self,
            PaymentMethodEntity.self,
            ContactEntity.self,
            ContactPaymentMethod.self,
            GroupEntity.self
        ])
    }
}
