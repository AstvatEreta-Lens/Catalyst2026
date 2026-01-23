//
//  EditProfileView.swift
//  Talangin
//
//  Created by Rifqi Rahman on 19/01/26.
//
//  Edit profile view with gradient header and profile photo editing.
//  Matches the design with "< Profile" back button and "Save" action.
//
//  BACKEND DEVELOPER NOTES:
//  -------------------------
//  Profile Editing:
//  1. Validate name is not empty (minimum 2 characters)
//  2. Validate email format before saving
//  3. Update UserEntity via repository
//  4. Sync profile photo to CloudKit/server (compress before upload)
//  5. Handle validation errors gracefully
//
//  Photo Upload:
//  - Compress images before storage (max 500KB recommended)
//  - Support JPEG and PNG formats
//  - Consider using background upload for large files
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    
    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Properties from parent
    let currentName: String
    let currentEmail: String
    let currentPhone: String?
    let currentPhotoData: Data?
    let accountBadge: String
    let onSave: (String, String, String?, Data?) -> Void
    
    // MARK: - Local State
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var profilePhotoData: Data?
    @State private var showPhotoOptions = false
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showValidationError = false
    @State private var validationMessage = ""
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // MARK: - Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                // MARK: - Gradient Header
                gradientHeader
                
                // MARK: - Content
                ScrollView {
                    VStack(spacing: 0) {
                        // Spacer for gradient area
                        Color.clear
                            .frame(height: 200)
                        
                        // Profile Form
                        profileFormSection
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveProfile()
                    }
                    .fontWeight(.semibold)
                    .disabled(!hasChanges || !isValid)
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .sheet(isPresented: $showPhotoOptions) {
                PhotoOptionsSheet(
                    onTakePhoto: {
                        showPhotoOptions = false
                        showCamera = true
                    },
                    onChoosePhoto: {
                        showPhotoOptions = false
                        showImagePicker = true
                    },
                    onEmojiSticker: {
                        // BACKEND NOTE: Implement emoji/sticker picker
                        showPhotoOptions = false
                    }
                )
                .presentationDetents([.height(280)])
                .presentationDragIndicator(.visible)
            }
            .photosPicker(
                isPresented: $showImagePicker,
                selection: $selectedPhotoItem,
                matching: .images
            )
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        profilePhotoData = data
                    }
                }
            }
            .alert("Validation Error", isPresented: $showValidationError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(validationMessage)
            }
            .onAppear {
                name = currentName
                email = currentEmail
                phone = currentPhone ?? ""
                profilePhotoData = currentPhotoData
            }
        }
    }
    
    // MARK: - Gradient Header
    private var gradientHeader: some View {
        ZStack {
            Rectangle()
              .foregroundColor(.clear)
              .background(
                LinearGradient(
                  stops: [
                    Gradient.Stop(color: Color(red: 0.17, green: 0.28, blue: 0.7), location: 0.00),
                    Gradient.Stop(color: Color(red: 0.12, green: 0.54, blue: 0.48), location: 0.82),
                    Gradient.Stop(color: Color(red: 0.09, green: 0.71, blue: 0.28), location: 1.00),
                  ],
                  startPoint: UnitPoint(x: 0.02, y: 0),
                  endPoint: UnitPoint(x: 1, y: 1.04)
                )
              )
            
            // Profile Photo Section
            VStack(spacing: AppSpacing.md) {
                // Profile Photo with Camera Button
                ZStack(alignment: .bottomTrailing) {
                    // Photo
                    if let photoData = profilePhotoData,
                       let uiImage = UIImage(data: photoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Text(initials)
                                    .font(.Title1)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            )
                    }
                    
                    // Camera Button
                    Button {
                        showPhotoOptions = true
                    } label: {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
                    }
                    .offset(x: 4, y: 4)
                }
                
                // Account Badge
                Text(accountBadge)
                    .font(.Caption)
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.primary)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.xxs)
                    .background(
                        Capsule()
                            .fill(Color.white)
                    )
            }
            .padding(.top, AppSpacing.xxxl)
        }
        .frame(height: 280)
        .ignoresSafeArea(edges: .top)
    }
    
    // MARK: - Profile Form Section
    private var profileFormSection: some View {
        VStack(spacing: 0) {
            // Section Header
            HStack {
                Text("PROFILE")
                    .font(.Caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.lg)
            .padding(.bottom, AppSpacing.xs)
            
            // Form Fields
            VStack(spacing: 0) {
                // Name Field
                HStack {
                    TextField("Enter your name", text: $name)
                        .font(.Body)
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.vertical, AppSpacing.md)
                .background(Color(.systemBackground))
                
                Divider()
                    .padding(.leading, AppSpacing.lg)
                
                // Email Field
                HStack {
                    TextField("Enter your email", text: $email)
                        .font(.Body)
                        .foregroundColor(.primary)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.vertical, AppSpacing.md)
                .background(Color(.systemBackground))
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .background(
            RoundedCorner(radius: 24, corners: [.topLeft, .topRight])
                .fill(Color(.systemGroupedBackground))
        )
    }
    
    // MARK: - Computed Properties
    
    private var initials: String {
        let components = name.split(separator: " ")
        let firstInitial = components.first?.first.map(String.init) ?? ""
        let lastInitial = components.count > 1 ? components.last?.first.map(String.init) ?? "" : ""
        return (firstInitial + lastInitial).uppercased()
    }
    
    private var hasChanges: Bool {
        name != currentName ||
        email != currentEmail ||
        phone != (currentPhone ?? "") ||
        profilePhotoData != currentPhotoData
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
        
        let phoneToSave = phone.isEmpty ? nil : phone
        onSave(name.trimmingCharacters(in: .whitespaces), email, phoneToSave, profilePhotoData)
        dismiss()
    }
}

// MARK: - Photo Options Sheet

private struct PhotoOptionsSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    
    let onTakePhoto: () -> Void
    let onChoosePhoto: () -> Void
    let onEmojiSticker: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                // Photo Preview
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.gray)
                    )
                
                Text("Edit Profile Picture")
                    .font(.Headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)
            
            Divider()
            
            // Options
            VStack(spacing: 0) {
                // Take Photo
                PhotoOptionRow(
                    title: "Take Photo",
                    icon: "camera",
                    action: onTakePhoto
                )
                
                Divider()
                    .padding(.leading, AppSpacing.lg)
                
                // Choose Photo
                PhotoOptionRow(
                    title: "Choose Photo",
                    icon: "photo",
                    action: onChoosePhoto
                )
                
                Divider()
                    .padding(.leading, AppSpacing.lg)
                
                // Emoji & Sticker
                PhotoOptionRow(
                    title: "Emoji & Sticker",
                    icon: "square.on.square",
                    action: onEmojiSticker
                )
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.md)
            
            Spacer()
        }
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Photo Option Row

private struct PhotoOptionRow: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                Text(title)
                    .font(.Body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)
        }
    }
}

#Preview {
    EditProfileView(
        currentName: "Rifqi Smith",
        currentEmail: "john.doe@gmail.com",
        currentPhone: nil,
        currentPhotoData: nil,
        accountBadge: "Free Account"
    ) { name, email, phone, photoData in
        print("Saved: \(name), \(email)")
    }
}
