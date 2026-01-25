//
//  FriendSelectionRow.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 12/01/26.
//

import SwiftUI

struct FriendSelectionRow: View {
    let friend: FriendEntity
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Avatar circle
                Text(friend.avatarInitials)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
                    .background(Color(uiColor: .systemGray5))
                    .clipShape(Circle())
                
                // Friend name
                Text(friend.fullName ?? "")
                    .font(.body)
                    .foregroundColor(.primary)
                
                
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
    let friend = FriendEntity(userId: "1", fullName: "Budi")
    
    VStack {
        FriendSelectionRow(friend: friend, isSelected: false, onTap: {})
        FriendSelectionRow(friend: friend, isSelected: true, onTap: {})
    }
    .padding()
}
