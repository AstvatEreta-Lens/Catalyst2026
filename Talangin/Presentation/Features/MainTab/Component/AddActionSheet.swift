//
//  AddActionSheet.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 10/01/26.
//

import SwiftUI

struct AddActionSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    let onAddExpenses: () -> Void
    let onCreateGroup: () -> Void
    let onJoinWithLink: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Action buttons
            VStack(spacing: 12) {
                ActionButton(
                    icon: "plus.circle.fill",
                    title: "Add Expenses",
                    color: .blue
                ) {
                    dismiss()
                    onAddExpenses()
                }
                
                ActionButton(
                    icon: "person.3.fill",
                    title: "Create New Group",
                    color: .green
                ) {
                    dismiss()
                    onCreateGroup()
                }
                
                ActionButton(
                    icon: "link.circle.fill",
                    title: "Join with Link",
                    color: .orange
                ) {
                    dismiss()
                    onJoinWithLink()
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
        .presentationDetents([.fraction(0.35)])
        .presentationDragIndicator(.visible)
    }
}

struct ActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                    .frame(width: 44, height: 44)
                    .background(color.opacity(0.1))
                    .clipShape(Circle())
                
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray.opacity(0.5))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(uiColor: .secondarySystemBackground))
            .cornerRadius(12)
        }
    }
}

#Preview {
    AddActionSheet(
        onAddExpenses: { print("Add Expenses") },
        onCreateGroup: { print("Create Group") },
        onJoinWithLink: { print("Join Link") }
    )
}
