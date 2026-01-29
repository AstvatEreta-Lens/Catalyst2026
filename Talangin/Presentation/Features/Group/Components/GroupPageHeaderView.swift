//
//  GroupPageHeaderView.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 25/01/26.
//

import SwiftUI

import PhotosUI

struct GroupPageHeaderView: View {
    @ObservedObject var viewModel: GroupPageViewModel
    @State private var selectedItem: PhotosPickerItem?
    
    var group: GroupEntity {
        viewModel.group
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                // Gradient Background
                LinearGradient(
                    colors: [
                        Color(red: 0.17, green: 0.28, blue: 0.7), // Blue
                        Color(red: 0.12, green: 0.54, blue: 0.48) // Teal
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 200)
                
                // Group Icon Overlap
                ZStack {
                    if let imageData = group.groupPhotoData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 31.5))
                    } else {
                        GroupIconView(group: group, size: .large)
                            .frame(width: 100, height: 100)
                            .background(Color(red: 0.9, green: 0.95, blue: 1.0)) // Light blue tint
                            .clipShape(RoundedRectangle(cornerRadius: 31.5))
                    }
                    
                    // Edit Icon Overlay
//                    PhotosPicker(selection: $selectedItem, matching: .images) {
//                        ZStack {
//                            Circle()
//                                .fill(.black.opacity(0.5))
//                                .frame(width: 32, height: 32)
//                            Image(systemName: "camera.fill")
//                                .font(.system(size: 14))
//                                .foregroundColor(.white)
//                        }
//                    }
//                    .offset(x: 35, y: 35)
                }
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                .offset(x: 24, y: 30)
                .onChange(of: selectedItem) {
                    Task {
                        if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                            viewModel.updateGroupImage(data: data)
                        }
                    }
                }
            }
            .zIndex(1)
            
            // Info Section
            VStack(alignment: .leading, spacing: 4) {
                Spacer().frame(height: 50) // Space for overlapping icon
                
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        
                        HStack {
                            Text(group.name ?? "Untitled Group")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.primary)
                            
//                            Button {
//                                viewModel.editedName = group.name ?? ""
//                                viewModel.isEditingName = true
//                            } label: {
//                                Image(systemName: "pencil")
//                                    .font(.system(size: 16, weight: .medium))
//                                    .foregroundColor(.secondary)
//                            }
                        }
                    
                        
                        Text("\(group.memberCount) Members")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.secondary.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.system(size: 12))
                            Text("Due date")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(.secondary)
                        Text(group.createdAt?.formatted(date: .abbreviated, time: .omitted) ?? "20 Jan 2026")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.primary)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            .background(Color(uiColor:.systemGroupedBackground))
        }
    }
}

