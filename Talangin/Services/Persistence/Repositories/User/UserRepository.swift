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
           guard let appleUserId = KeychainService.load(for: "appleUserID") else {
               return nil
           }

           let predicate = #Predicate<UserEntity> {
               $0.appleUserId == appleUserId
           }

           let descriptor = FetchDescriptor(predicate: predicate)
           return try context.fetch(descriptor).first
       }

       // MARK: - Fetch by ID

       func getUser(by appleUserId: String) throws -> UserEntity? {
           let predicate = #Predicate<UserEntity> {
               $0.appleUserId == appleUserId
           }

           let descriptor = FetchDescriptor(predicate: predicate)
           return try context.fetch(descriptor).first
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
