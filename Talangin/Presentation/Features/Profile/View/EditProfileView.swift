//
//  EditProfileView.swift
//  Talangin
//
//  Created by Rifqi Rahman on 19/01/26.
//
//  Updated: Added profile photo editing with PhotosPicker and redesigned to match mockup.
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    
    @Environment(\.dismiss) private var dismiss

    // MARK: - Bindings from parent
    let currentName: String
    let currentEmail: String
    let currentPhone: String?
    let currentPhotoData: Data?
    let onSave: (String, String, String?, Data?) -> Void
    
    // MARK: - Local State
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var profileImage: UIImage?
    @State private var showValidationError = false
    @State private var validationMessage = ""

    var body: some View {
        ZStack(alignment: .top) {
            // MARK: - Background Color
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }

            VStack(spacing: 0) {
                // MARK: - Header Section
                headerSection
                
                // MARK: - Form Section
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("PROFILE")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 24)
                            .padding(.top, 24)
                        
                        VStack(spacing: 0) {
                            // Name field
                            customTextField(value: $name, placeholder: "Name")
                            
                            Divider()
                                .padding(.leading, 20)
                            
                            // Email field
                            customTextField(value: $email, placeholder: "Email", keyboardType: .emailAddress)
                        }
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 16)
                        
                        // Phone section
                        Text("PHONE")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 24)
                            .padding(.top, 8)
                        
                        VStack(spacing: 0) {
                            customTextField(value: $phone, placeholder: "Phone", keyboardType: .phonePad)
                        }
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 16)
                    }
                    .padding(.bottom, 30)
                }
            }
            .ignoresSafeArea(edges: .top)
        }
        .navigationBarHidden(true)
        .alert("Validation Error", isPresented: $showValidationError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(validationMessage)
        }
        .onAppear {
            name = currentName
            email = currentEmail
            phone = currentPhone ?? ""
            if let data = currentPhotoData {
                profileImage = UIImage(data: data)
            }
        }
        .onChange(of: selectedItem) { oldItem, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    await MainActor.run {
                        profileImage = uiImage
                    }
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var hasChanges: Bool {
        let nameChanged = name != currentName
        let emailChanged = email != currentEmail
        let phoneChanged = phone != (currentPhone ?? "")
        let photoChanged = (profileImage?.jpegData(compressionQuality: 0.8)) != currentPhotoData
        
        return nameChanged || emailChanged || phoneChanged || photoChanged
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
        let photoToSave = profileImage?.jpegData(compressionQuality: 0.8)
        onSave(name.trimmingCharacters(in: .whitespaces), email, phoneToSave, photoToSave)
        dismiss()
    }
}

// MARK: - Components
private extension EditProfileView {
    
    func customTextField(value: Binding<String>, placeholder: String, keyboardType: UIKeyboardType = .default) -> some View {
        TextField(placeholder, text: value)
            .font(.system(size: 16))
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
            .keyboardType(keyboardType)
            .textInputAutocapitalization(keyboardType == .emailAddress ? .never : .words)
            .autocorrectionDisabled(keyboardType == .emailAddress)
    }
    
    var headerSection: some View {
        ZStack(alignment: .top) {
            // Gradient Background
            LinearGradient(
                stops: [
                    Gradient.Stop(color: Color(red: 0.17, green: 0.28, blue: 0.7), location: 0.00),
                    Gradient.Stop(color: Color(red: 0.12, green: 0.54, blue: 0.48), location: 0.82),
                    Gradient.Stop(color: Color(red: 0.09, green: 0.71, blue: 0.28), location: 1.00),
                ],
                startPoint: UnitPoint(x: 0.02, y: 0),
                endPoint: UnitPoint(x: 1, y: 1.04)
            )
            .frame(height: 320)
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Navigation Bar
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                            Text("Profile")
                                .font(.system(size: 17))
                        }
                        .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Button("Save") {
                        saveProfile()
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .opacity(isValid ? 1.0 : 0.6)
                    .disabled(!isValid)
                }
                .padding(.horizontal, 16)
                .padding(.top, 44 + 10) // Approx status bar + margin
                
                Spacer()
                
                // Profile Photo
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    ZStack(alignment: .bottom) {
                        ZStack {
                            if let profileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 90, height: 90)
                                    .clipShape(Circle())
                            } else {
                                Circle()
                                    .fill(Color.white.opacity(0.3))
                                    .frame(width: 90, height: 90)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 40)
                                            .foregroundColor(.white)
                                    )
                            }
                        }
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        
                        // Camera overlay circle (Centered at bottom overlap)
                        Circle()
                            .fill(Color.white)
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                            )
                            .offset(y: 16)
                    }
                }
                .buttonStyle(.plain)
                .padding(.bottom, 32)
                
                // Badge
                Text("Free Account")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(red: 0.09, green: 0.45, blue: 0.6))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.9))
                    .clipShape(Capsule())
                    .padding(.bottom, 24)
            }
            .frame(height: 320)
        }
    }
}

#Preview {
    EditProfileView(
        currentName: "Rifqi Smith",
        currentEmail: "john.doe@gmail.com",
        currentPhone: "081234567890",
        currentPhotoData: nil
    ) { name, email, phone, photo in
        print("Saved: \(name), \(email), \(phone ?? "no phone"), photo: \(photo != nil)")
    }
}
