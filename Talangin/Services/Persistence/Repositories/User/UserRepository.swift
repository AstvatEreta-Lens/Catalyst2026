//
//  UserRepository.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 07/01/26.
//

import SwiftData
import Foundation

@MainActor
final class UserRepository: UserRepositoryProtocol {
    private let context: ModelContext

       init(context: ModelContext) {
           self.context = context
       }

       // MARK: - Current User (ACTIVE SESSION)

       func getCurrentUser() throws -> UserEntity? {
           print("🔍 UserRepository: Fetching current user...")
           guard let appleUserId = KeychainService.load(for: "appleUserID") else {
               print("⚠️ UserRepository: No appleUserID found in Keychain")
               return nil
           }
           print("🔑 UserRepository: Found appleUserID: \(appleUserId)")

           let predicate = #Predicate<UserEntity> { user in
               user.appleUserId == appleUserId
           }

           let descriptor = FetchDescriptor(predicate: predicate)
           let results = try context.fetch(descriptor)
           print("📊 UserRepository: Found \(results.count) users matching ID")
           return results.first
       }

       // MARK: - Fetch by ID

       func getUser(by appleUserId: String) throws -> UserEntity? {
           print("🔍 UserRepository: Fetching user by ID: \(appleUserId)")
           let predicate = #Predicate<UserEntity> { user in
               user.appleUserId == appleUserId
           }

           let descriptor = FetchDescriptor(predicate: predicate)
           let results = try context.fetch(descriptor)
           print("📊 UserRepository: Found \(results.count) users matching ID")
           return results.first
       }

       // MARK: - Upsert

       func upsertUser(
           appleUserId: String,
           fullName: String?,
           email: String?
       ) throws {

           if let existing = try getUser(by: appleUserId) {
               if existing.fullName == nil {
                   existing.fullName = fullName
               }
               if existing.email == nil {
                   existing.email = email
               }
               try save()
               return
           }

           let user = UserEntity(
               appleUserId: appleUserId,
               fullName: fullName,
               email: email
           )

           context.insert(user)
           try save()
       }

       // MARK: - Update

       func updatePhoneNumber(_ phone: String?) {
           try? getCurrentUser()?.phoneNumber = phone
       }

       func updateProfilePhoto(_ data: Data?) {
           try? getCurrentUser()?.profilePhotoData = data
       }

       // MARK: - Persist

       func save() throws {
           try context.save()
       }
}
