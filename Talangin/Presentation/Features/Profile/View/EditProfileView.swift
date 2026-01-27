//
//  EditProfileView.swift
//  Talangin
//
//  Created by Rifqi Rahman on 19/01/26.
//
//  Edit profile sheet for updating user name, email, and phone number.
//
//  BACKEND DEVELOPER NOTES:
//  -------------------------
//  This view allows users to edit their profile information.
//  
//  Integration requirements:
//  1. Validate email format before saving
//  2. Validate phone number format (Indonesian format)
//  3. Update UserEntity via repository
//  4. Sync changes to CloudKit/server
//  5. Handle validation errors gracefully
//

import SwiftUI
import PhotosUI
import UIKit

struct EditProfileView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Bindings from parent
    let currentName: String
    let currentEmail: String
    let currentPhone: String?
    let currentPhotoData: Data?
    let onSave: (String, String, String?) -> Void
    let onPhotoChanged: ((Data) -> Void)?
    
    // MARK: - Local State
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var showValidationError = false
    @State private var validationMessage = ""
    @State private var selectedItem: PhotosPickerItem?
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: - Profile Photo Section
                Section {
                    VStack(spacing: 16) {
                        // Profile Photo with overlay
                        Button {
                            // Photo picker will be triggered via PhotosPicker overlay
                        } label: {
                            ZStack {
                                // Profile Photo
                                Group {
                                    if let photoData = currentPhotoData,
                                       let uiImage = UIImage(data: photoData) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                    } else {
                                        Image(systemName: "person.crop.circle.fill")
                                            .resizable()
                                            .foregroundStyle(.gray)
                                    }
                                }
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                
                                // Subtle dark overlay with camera icon
                                Circle()
                                    .fill(Color.black.opacity(0.3))
                                    .frame(width: 100, height: 100)
                                
                                // Camera icon
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                            }
                        }
                        .buttonStyle(.plain)
                        .overlay(
                            PhotosPicker(
                                selection: $selectedItem,
                                matching: .images
                            ) {
                                EmptyView()
                            }
                            .opacity(0)
                            .frame(width: 100, height: 100)
                        )
                        .onChange(of: selectedItem) {
                            Task {
                                if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                                    onPhotoChanged?(data)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                
                // MARK: - Profile Section
                Section {
                    // Name Field
                    HStack {
                        Text("Name")
                            .foregroundColor(.primary)
                        Spacer()
                        TextField("Enter your name", text: $name)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.primary)
                    }
                    
                    // Email Field
                    HStack {
                        Text("Email")
                            .foregroundColor(.primary)
                        Spacer()
                        TextField("Enter your email", text: $email)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.primary)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                    
                    // Phone Field
                    HStack {
                        Text("Phone")
                            .foregroundColor(.primary)
                        Spacer()
                        TextField("Enter phone number", text: $phone)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.primary)
                            .keyboardType(.phonePad)
                    }
                } header: {
                    Text("PROFILE INFORMATION")
                } footer: {
                    Text("Your name and email are visible to friends you share expenses with.")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProfile()
                    }
                    .fontWeight(.semibold)
                    .disabled(!hasChanges || !isValid)
                }
            }
            .alert("Validation Error", isPresented: $showValidationError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(validationMessage)
            }
            .onAppear {
                // Initialize with current values
                name = currentName
                email = currentEmail
                phone = currentPhone ?? ""
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var hasChanges: Bool {
        name != currentName ||
        email != currentEmail ||
        phone != (currentPhone ?? "")
    }
    
    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        isValidEmail(email)
    }
    
    // MARK: - Validation
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    // MARK: - Actions
    
    private func saveProfile() {
        // Validate
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            validationMessage = "Please enter your name."
            showValidationError = true
            return
        }
        
        guard isValidEmail(email) else {
            validationMessage = "Please enter a valid email address."
            showValidationError = true
            return
        }
        
        // Save
        let phoneToSave = phone.isEmpty ? nil : phone
        onSave(name.trimmingCharacters(in: .whitespaces), email, phoneToSave)
        dismiss()
    }
}

#Preview {
    EditProfileView(
        currentName: "John Doe",
        currentEmail: "john.doe@gmail.com",
        currentPhone: "081234567890",
        currentPhotoData: nil,
        onSave: { name, email, phone in
            print("Saved: \(name), \(email), \(phone ?? "no phone")")
        },
        onPhotoChanged: { data in
            print("Photo changed: \(data.count) bytes")
        }
    )
}
