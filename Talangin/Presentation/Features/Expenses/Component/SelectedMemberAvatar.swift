//
//  SelectedMemberAvatar.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 12/01/26.
//

import SwiftUI

struct SelectedMemberAvatar: View {
    let initials: String
    
    var body: some View {
        Text(initials)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.primary)
            .frame(width: 44, height: 44)
            .background(Color(uiColor: .systemGray5))
            .clipShape(Circle())
    }
}

#Preview {
    HStack(spacing: 12) {
        SelectedMemberAvatar(initials: "CH")
        SelectedMemberAvatar(initials: "AL")
        SelectedMemberAvatar(initials: "RQ")
    }
    .padding()
}
