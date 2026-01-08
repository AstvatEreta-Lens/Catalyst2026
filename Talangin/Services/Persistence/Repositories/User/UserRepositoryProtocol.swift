//
//  UserRepositoryProtocol.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 07/01/26.
//

import Foundation


protocol UserRepositoryProtocol {
    // MARK: - Fetch
       func getCurrentUser() throws -> UserEntity?
       func getUser(by appleUserId: String) throws -> UserEntity?

       // MARK: - Create / Upsert
       func upsertUser(
           appleUserId: String,
           fullName: String?,
           email: String?
       ) throws

       // MARK: - Update
       func updatePhoneNumber(_ phone: String?)
       func updateProfilePhoto(_ data: Data?)

       // MARK: - Persist
       func save() throws
}
