//
//  GroupSelectionRow.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 12/01/26.
//

import SwiftUI

struct GroupSelectionRow: View {
    let group: GroupEntity
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Avatar circle
                Text(group.avatarInitials)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
                    .background(Color(uiColor: .systemGray5))
                    .clipShape(Circle())
                
                // Group info
                VStack(alignment: .leading, spacing: 2) {
                    Text(group.name ?? "")
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Text("\(group.memberCount) members")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Checkmark
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                }
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let friend1 = FriendEntity(userId: "1", fullName: "Budi")
    let friend2 = FriendEntity(userId: "2", fullName: "Santoso")
    let friend3 = FriendEntity(userId: "3", fullName: "Ria")
    
    let group = GroupEntity(name: "Kemping", members: [friend1, friend2, friend3])
    
    VStack {
        GroupSelectionRow(group: group, isSelected: false, onTap: {})
        GroupSelectionRow(group: group, isSelected: true, onTap: {})
    }
    .padding()
}
