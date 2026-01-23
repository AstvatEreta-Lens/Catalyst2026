//
//  EditProfileView.swift
//  Talangin
//
//  Created by Rifqi Rahman on 19/01/26.
//
//  Profile view with view/edit modes. Shows profile info read-only by default.
//  Tapping "Edit" button enables editing mode with "Save" button.
//  Uses SwiftUI, PhotosUI, and AVFoundation for photo selection.
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
    @State private var isEditing = false
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var profilePhotoData: Data?
    @State private var showPhotoOptions = false
    @State private var showEmojiPicker = false
    @State private var showValidationError = false
    @State private var validationMessage = ""
    @State private var showCamera = false
    
    // PhotosPicker state
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showPhotoPicker = false
    
    // Pending action after sheet dismissal
    @State private var pendingAction: PhotoAction? = nil
    
    private enum PhotoAction {
        case camera
        case library
        case emoji
    }
    
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
                    Button("Back") {
                        if isEditing {
                            // Cancel editing - revert changes
                            cancelEditing()
                        } else {
                            dismiss()
                        }
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    if isEditing {
                        Button("Save") {
                            saveProfile()
                        }
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .disabled(!hasChanges || !isValid)
                        .opacity(hasChanges && isValid ? 1 : 0.6)
                    } else {
                        Button("Edit") {
                            startEditing()
                        }
                        .foregroundColor(.white)
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .sheet(isPresented: $showPhotoOptions, onDismiss: handlePhotoOptionsDismissed) {
                PhotoOptionsSheet(
                    onTakePhoto: {
                        pendingAction = .camera
                        showPhotoOptions = false
                    },
                    onChoosePhoto: {
                        pendingAction = .library
                        showPhotoOptions = false
                    },
                    onEmojiSticker: {
                        pendingAction = .emoji
                        showPhotoOptions = false
                    }
                )
                .presentationDetents([.height(280)])
                .presentationDragIndicator(.visible)
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraView(isPresented: $showCamera) { imageData in
                    profilePhotoData = imageData
                }
            }
            .photosPicker(
                isPresented: $showPhotoPicker,
                selection: $selectedPhotoItem,
                matching: .images,
                photoLibrary: .shared()
            )
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    await loadPhoto(from: newItem)
                }
            }
            .sheet(isPresented: $showEmojiPicker) {
                EmojiStickerPicker { emoji in
                    profilePhotoData = createEmojiImageData(emoji: emoji)
                }
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
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
                // Profile Photo - Only tappable in edit mode
                if isEditing {
                    Button {
                        showPhotoOptions = true
                    } label: {
                        ZStack(alignment: .bottomTrailing) {
                            profileImageView
                            
                            // Edit Button Overlay
                            Circle()
                                .fill(Color.white)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                )
                                .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
                                .offset(x: 4, y: 4)
                        }
                    }
                    .buttonStyle(.plain)
                } else {
                    profileImageView
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
    
    // MARK: - Profile Image View
    @ViewBuilder
    private var profileImageView: some View {
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
                    if isEditing {
                        TextField("Enter your name", text: $name)
                            .font(.Body)
                            .foregroundColor(.primary)
                    } else {
                        Text(name.isEmpty ? "John Doe" : name)
                            .font(.Body)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.vertical, AppSpacing.md)
                .background(Color(.systemBackground))
                
                Divider()
                    .padding(.leading, AppSpacing.lg)
                
                // Email Field
                HStack {
                    if isEditing {
                        TextField("Enter your email", text: $email)
                            .font(.Body)
                            .foregroundColor(.primary)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    } else {
                        Text(email.isEmpty ? "john.doe@gmail.com" : email)
                            .font(.Body)
                            .foregroundColor(.primary)
                        Spacer()
                    }
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
    
    // MARK: - Actions
    
    private func startEditing() {
        isEditing = true
    }
    
    private func cancelEditing() {
        // Revert to original values
        name = currentName
        email = currentEmail
        phone = currentPhone ?? ""
        profilePhotoData = currentPhotoData
        isEditing = false
    }
    
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
        isEditing = false
    }
    
    /// Handles the pending action after photo options sheet is dismissed
    private func handlePhotoOptionsDismissed() {
        guard let action = pendingAction else { return }
        pendingAction = nil
        
        // Small delay to ensure sheet dismissal animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            switch action {
            case .camera:
                showCamera = true
            case .library:
                showPhotoPicker = true
            case .emoji:
                showEmojiPicker = true
            }
        }
    }
    
    /// Loads photo data from PhotosPickerItem
    @MainActor
    private func loadPhoto(from item: PhotosPickerItem?) async {
        guard let item = item else { return }
        
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                // Compress the image
                if let image = UIImage(data: data),
                   let compressedData = image.jpegData(compressionQuality: 0.6) {
                    profilePhotoData = compressedData
                } else {
                    profilePhotoData = data
                }
            }
        } catch {
            validationMessage = "Failed to load image. Please try again."
            showValidationError = true
        }
        
        // Reset selection for next pick
        selectedPhotoItem = nil
    }
    
    /// Creates image data from emoji using ImageRenderer (SwiftUI)
    @MainActor
    private func createEmojiImageData(emoji: String) -> Data? {
        let emojiView = ZStack {
            Circle()
                .fill(Color(.systemGray5))
                .frame(width: 200, height: 200)
            
            Text(emoji)
                .font(.system(size: 100))
        }
        .frame(width: 200, height: 200)
        
        let renderer = ImageRenderer(content: emojiView)
        renderer.scale = 2.0
        
        if let uiImage = renderer.uiImage {
            return uiImage.pngData()
        }
        return nil
    }
    
    // MARK: - Validation
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
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
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .symbolRenderingMode(.hierarchical)
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
                    icon: "face.smiling",
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

// MARK: - Emoji Sticker Picker

private struct EmojiStickerPicker: View {
    let onEmojiSelected: (String) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: EmojiCategory = .smileys
    
    // Common profile-friendly emojis
    private let emojiCategories: [EmojiCategory: [String]] = [
        .smileys: ["😀", "😃", "😄", "😁", "😆", "😅", "🤣", "😂", "🙂", "😊", "😇", "🥰", "😍", "🤩", "😘", "😋", "😎", "🤓", "🧐", "🤠", "🥳", "🤗", "🤭", "😏", "😌", "😴", "🤤", "😷", "🤒", "🤕"],
        .people: ["👶", "👧", "🧒", "👦", "👩", "🧑", "👨", "👩‍🦱", "🧑‍🦱", "👨‍🦱", "👩‍🦰", "🧑‍🦰", "👨‍🦰", "👱‍♀️", "👱", "👱‍♂️", "👩‍🦳", "🧑‍🦳", "👨‍🦳", "👩‍🦲", "🧑‍🦲", "👨‍🦲", "🧔", "👵", "🧓", "👴", "👲", "👳‍♀️", "👳", "🧕"],
        .animals: ["🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐻‍❄️", "🐨", "🐯", "🦁", "🐮", "🐷", "🐸", "🐵", "🐔", "🐧", "🐦", "🐤", "🦆", "🦅", "🦉", "🦇", "🐺", "🐗", "🐴", "🦄", "🐝", "🦋"],
        .nature: ["🌸", "💮", "🏵️", "🌹", "🥀", "🌺", "🌻", "🌼", "🌷", "🌱", "🪴", "🌲", "🌳", "🌴", "🌵", "🌾", "🌿", "☘️", "🍀", "🍁", "🍂", "🍃", "🪺", "🪹", "🍄", "🌰", "🦀", "🦞", "🦐", "🦑"],
        .food: ["🍎", "🍐", "🍊", "🍋", "🍌", "🍉", "🍇", "🍓", "🫐", "🍈", "🍒", "🍑", "🥭", "🍍", "🥥", "🥝", "🍅", "🍆", "🥑", "🥦", "🥬", "🥒", "🌶️", "🫑", "🌽", "🥕", "🧄", "🧅", "🥔", "🍠"],
        .objects: ["⚽", "🏀", "🏈", "⚾", "🥎", "🎾", "🏐", "🏉", "🥏", "🎱", "🪀", "🏓", "🏸", "🏒", "🏑", "🥍", "🏏", "🪃", "🥅", "⛳", "🪁", "🎣", "🤿", "🎽", "🎿", "🛷", "🥌", "🎯", "🪀", "🎮"]
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category Picker
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppSpacing.md) {
                        ForEach(EmojiCategory.allCases, id: \.self) { category in
                            Button {
                                selectedCategory = category
                            } label: {
                                Text(category.icon)
                                    .font(.title2)
                                    .padding(.horizontal, AppSpacing.sm)
                                    .padding(.vertical, AppSpacing.xs)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(selectedCategory == category ? AppColors.primary.opacity(0.2) : Color.clear)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)
                }
                .padding(.vertical, AppSpacing.md)
                
                Divider()
                
                // Emoji Grid
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: AppSpacing.md) {
                        ForEach(emojiCategories[selectedCategory] ?? [], id: \.self) { emoji in
                            Button {
                                onEmojiSelected(emoji)
                                dismiss()
                            } label: {
                                Text(emoji)
                                    .font(.system(size: 36))
                            }
                        }
                    }
                    .padding(AppSpacing.lg)
                }
            }
            .navigationTitle("Choose Emoji")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Emoji Category

private enum EmojiCategory: CaseIterable {
    case smileys
    case people
    case animals
    case nature
    case food
    case objects
    
    var icon: String {
        switch self {
        case .smileys: return "😀"
        case .people: return "👤"
        case .animals: return "🐶"
        case .nature: return "🌸"
        case .food: return "🍎"
        case .objects: return "⚽"
        }
    }
    
    var title: String {
        switch self {
        case .smileys: return "Smileys"
        case .people: return "People"
        case .animals: return "Animals"
        case .nature: return "Nature"
        case .food: return "Food"
        case .objects: return "Objects"
        }
    }
}

#Preview {
    EditProfileView(
        currentName: "John Smith",
        currentEmail: "john.doe@gmail.com",
        currentPhone: nil,
        currentPhotoData: nil,
        accountBadge: "Free Account"
    ) { name, email, phone, photoData in
        print("Saved: \(name), \(email)")
    }
}
