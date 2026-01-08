//
//  ProfileHeaderView.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 07/01/26.
//


import SwiftUI
import PhotosUI

struct ProfileHeaderView: View {
    let imageData: Data?
    let onEditPhoto: (Data) -> Void

    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        HStack(spacing: 16) {
            Group {
                if let imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 80, height: 80)
            .clipShape(Circle())

            PhotosPicker("Edit Photo", selection: $selectedItem)
                .onChange(of: selectedItem) {
                    Task {
                        if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                            onEditPhoto(data)
                        }
                    }
                }
        }
    }
}