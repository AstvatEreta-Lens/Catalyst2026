//
//  FriendView.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 06/01/26.
//

import SwiftUI

struct FriendView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.green.gradient)
                
                Text("Friends")
                    .font(.largeTitle.bold())
                
                Text("Your connected friends list.")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Friends")
        }
    }
}

#Preview {
    FriendView()
}
