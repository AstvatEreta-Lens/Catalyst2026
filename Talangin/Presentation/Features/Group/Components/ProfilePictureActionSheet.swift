//
//  ProfilePictureActionSheet.swift
//  Talangin
//
//  Created by Rifqi Rahman on 27/01/26.
//
//  Action sheet for uploading or editing group profile picture.
//  Options: Take Photo, Choose Photo, Emoji & Sticker.
//
//  ARCHITECTURE NOTES:
//  -------------------
//  - Choose Photo: Uses PhotosUI (PhotosPicker) - Pure SwiftUI ✅
//  - Take Photo: Uses AVFoundation (CameraCaptureView) - Minimal UIKit ⚠️
//  - Emoji & Sticker: Uses SwiftUI ImageRenderer - Pure SwiftUI ✅
//
//  UIKit Usage (Minimal):
//  - UIImage: Required bridge for Data → SwiftUI.Image conversion
//  - UIViewRepresentable: Required for AVFoundation camera preview layer
//  - UIGraphicsImageRenderer: Fallback for emoji conversion
//

import SwiftUI
import PhotosUI
import AVFoundation
// NOTE: UIKit import is minimal - only used for:
// 1. UIImage conversion (Data to Image bridge - required by SwiftUI Image)
// 2. Camera preview layer (AVCaptureVideoPreviewLayer requires UIView)
// 3. ImageRenderer fallback (UIGraphicsImageRenderer - for emoji conversion)
import UIKit

struct ProfilePictureActionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var groupPhotoData: Data?
    let isEditMode: Bool
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var showImagePicker = false
    @State private var showEmojiPicker = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 12) {
                // Profile picture icon (left)
                Group {
                    if isEditMode, let photoData = groupPhotoData,
                       let image = Image(data: photoData) {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "camera")
                            .font(.system(size: 20))
                            .foregroundColor(.secondary)
                            .frame(width: 40, height: 40)
                    }
                }
                
                // Title (center)
                Text(isEditMode ? "Edit Profile Picture" : "Upload Profile Picture")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Close button (right)
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            Divider()
            
            // Options
            VStack(spacing: 0) {
                // Take Photo
                Button {
                    showImagePicker = true
                } label: {
                    HStack {
                        Text("Take Photo")
                            .font(.body)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "camera")
                            .font(.system(size: 18))
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                
                Divider()
                    .padding(.leading, 20)
                
                // Choose Photo
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images
                ) {
                    HStack {
                        Text("Choose Photo")
                            .font(.body)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 18))
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                .onChange(of: selectedItem) {
                    Task {
                        if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                            groupPhotoData = data
                            dismiss()
                        }
                    }
                }
                
                Divider()
                    .padding(.leading, 20)
                
                // Emoji & Sticker
                Button {
                    showEmojiPicker = true
                } label: {
                    HStack {
                        Text("Emoji & Sticker")
                            .font(.body)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "face.smiling")
                            .font(.system(size: 18))
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
        }
//        .background(Color(.systemBackground))
        .sheet(isPresented: $showImagePicker) {
            CameraCaptureView(imageData: $groupPhotoData)
        }
        .sheet(isPresented: $showEmojiPicker) {
            EmojiPickerView(selectedEmoji: Binding(
                get: { nil },
                set: { emoji in
                    if let emoji = emoji {
                        groupPhotoData = emoji.imageData(size: CGSize(width: 200, height: 200))
                        dismiss()
                    }
                }
            ))
        }
    }
}

// MARK: - Legacy Image Picker (Fallback)
/// Legacy UIImagePickerController-based camera picker.
/// Kept as fallback option if AVFoundation approach has issues.
/// NOTE: This is the simpler approach but less customizable than AVFoundation.
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var imageData: Data?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.allowsEditing = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.imageData = image.jpegData(compressionQuality: 0.8)
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Emoji Picker View
struct EmojiPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedEmoji: String?
    
    let emojis = ["😀", "😃", "😄", "😁", "😆", "😅", "🤣", "😂", "🙂", "🙃", "😉", "😊", "😇", "🥰", "😍", "🤩", "😘", "😗", "😚", "😙", "😋", "😛", "😜", "🤪", "😝", "🤑", "🤗", "🤭", "🤫", "🤔", "🤐", "🤨", "😐", "😑", "😶", "😏", "😒", "🙄", "😬", "🤥", "😌", "😔", "😪", "🤤", "😴", "😷", "🤒", "🤕", "🤢", "🤮", "🤧", "🥵", "🥶", "😶‍🌫️", "😵", "🤯", "🤠", "🥳", "🥸", "😎", "🤓", "🧐"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 20) {
                    ForEach(emojis, id: \.self) { emoji in
                        Button {
                            selectedEmoji = emoji
                            dismiss()
                        } label: {
                            Text(emoji)
                                .font(.system(size: 40))
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Emoji & Sticker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - String Extension for Emoji to Image Data
extension String {
    /// Converts emoji string to image data using SwiftUI ImageRenderer
    func imageData(size: CGSize) -> Data? {
        // Use SwiftUI ImageRenderer for emoji (iOS 16+)
        let renderer = ImageRenderer(content: Text(self).font(.system(size: size.height * 0.8)))
        renderer.scale = UIScreen.main.scale
        
        if let uiImage = renderer.uiImage {
            return uiImage.pngData()
        }
        
        // Fallback: create image from emoji text using UIKit (minimal UIKit usage)
        return createEmojiImageDataFallback(size: size)
    }
    
    /// Fallback method using minimal UIKit for image creation
    private func createEmojiImageDataFallback(size: CGSize) -> Data? {
        // Note: UIKit is only used here for image rendering fallback
        // This is necessary because SwiftUI ImageRenderer.uiImage requires UIKit bridge
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        
        let image = renderer.image { _ in
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: size.height * 0.8)
            ]
            let attributedString = NSAttributedString(string: self, attributes: attributes)
            let textSize = attributedString.size()
            let rect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            attributedString.draw(in: rect)
        }
        
        return image.pngData()
    }
}

#Preview("Upload Mode") {
    ProfilePictureActionSheet(
        groupPhotoData: .constant(nil),
        isEditMode: false
    )
    .presentationDetents([.fraction(0.33)])
    .presentationDragIndicator(.visible)
}

#Preview("Edit Mode") {
    // Create sample image data for preview
    let sampleImage = UIImage(systemName: "person.3.fill")?.pngData()
    
    return ProfilePictureActionSheet(
        groupPhotoData: .constant(sampleImage),
        isEditMode: true
    )
    .presentationDetents([.fraction(0.33)])
    .presentationDragIndicator(.visible)
}
