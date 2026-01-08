//
//  TalanginApp.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 01/01/26.
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
                    UserEntity.self,
                    PaymentMethodEntity.self
                ])
    }
}
