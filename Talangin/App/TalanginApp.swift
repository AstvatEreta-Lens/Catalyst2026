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
    
    init() {
        print("📁 Database Path: \(URL.applicationSupportDirectory.path(percentEncoded: false))")
    }
    
    var body: some Scene {
        WindowGroup {
            AuthGateView()
                .environmentObject(authState)
                .onAppear {
                    // Alternative way to find DB path in logs
                    if let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
                        print("📁 App Support Directory: \(url.path)")
                    }
              
                }
        }
        .modelContainer(sharedModelContainer)

    }
    private let sharedModelContainer: ModelContainer = {
        let schema = Schema([
            UserEntity.self,
            PaymentMethodEntity.self,
            ExpenseEntity.self,
            GroupEntity.self,
            FriendEntity.self,
            SplitParticipantEntity.self,
            ExpenseItemEntity.self,
            ContactEntity.self,
            ContactPaymentMethod.self
        ])
        
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            // Print detailed error information
            print("❌ SwiftData Error Details:")
            print("Error: \(error)")
            print("Error localized: \(error.localizedDescription)")
            
            if let swiftDataError = error as? any LocalizedError {
                print("Failure reason: \(swiftDataError.failureReason ?? "Unknown")")
                print("Recovery suggestion: \(swiftDataError.recoverySuggestion ?? "None")")
            }
            
            fatalError("Could not configure SwiftData container: \(error)")
        }
    }()
}
