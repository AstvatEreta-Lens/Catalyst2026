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
           print("🔄 UserRepository: Upserting user with ID: \(appleUserId)")

           if let existing = try getUser(by: appleUserId) {
               print("✏️ UserRepository: User exists, updating...")
               var updated = false
               
               if existing.fullName == nil {
                   existing.fullName = fullName
                   print("  ✅ Updated fullName: \(fullName ?? "nil")")
                   updated = true
               }
               if existing.email == nil {
                   existing.email = email
                   print("  ✅ Updated email: \(email ?? "nil")")
                   updated = true
               }
               
               if updated {
                   try save()
                   print("✅ UserRepository: User updated successfully")
               } else {
                   print("ℹ️ UserRepository: No updates needed")
               }
               return
           }

           print("➕ UserRepository: Creating new user...")
           let user = UserEntity(
               appleUserId: appleUserId,
               fullName: fullName,
               email: email
           )

           context.insert(user)
           try save()
           print("✅ UserRepository: New user created successfully")
       }

       // MARK: - Update

       func updatePhoneNumber(_ phone: String?) {
           print("✏️ UserRepository: Updating phone number...")
           do {
               if let user = try getCurrentUser() {
                   user.phoneNumber = phone
                   print("✅ UserRepository: Phone number updated to: \(phone ?? "nil")")
               } else {
                   print("❌ UserRepository: No current user found to update phone")
               }
           } catch {
               print("❌ UserRepository: Failed to update phone - \(error.localizedDescription)")
           }
       }

       func updateProfilePhoto(_ data: Data?) {
           print("✏️ UserRepository: Updating profile photo...")
           do {
               if let user = try getCurrentUser() {
                   user.profilePhotoData = data
                   let sizeKB = (data?.count ?? 0) / 1024
                   print("✅ UserRepository: Profile photo updated (\(sizeKB) KB)")
               } else {
                   print("❌ UserRepository: No current user found to update photo")
               }
           } catch {
               print("❌ UserRepository: Failed to update photo - \(error.localizedDescription)")
           }
       }

       // MARK: - Persist

       func save() throws {
           print("💾 UserRepository: Saving context...")
           do {
               try context.save()
               print("✅ UserRepository: Context saved successfully")
           } catch {
               print("❌ UserRepository: Failed to save context - \(error.localizedDescription)")
               throw error
           }
       }
}
