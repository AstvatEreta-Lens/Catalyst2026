//
//  CustomTabBar.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 08/01/26.
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: TabDestination
    let tabs: [TabItem]
    let onAddTap: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            // Left side - Home
            if let homeTab = tabs.first(where: { $0.destination == .home }) {
                TabBarButton(
                    tab: homeTab,
                    isSelected: selectedTab == .home,
                    action: { selectedTab = .home }
                )
            }
            
            Spacer()
            
            // Center - Add Button
            Button(action: onAddTap) {
                ZStack {
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 56, height: 56)
                        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .offset(y: -16)
            Spacer()
            
            // Right side - Profile
            if let profileTab = tabs.first(where: { $0.destination == .profile }) {
                TabBarButton(
                    tab: profileTab,
                    isSelected: selectedTab == .profile,
                    action: { selectedTab = .profile }
                )
            }
        }
        .padding(.horizontal, 24)
        .background(
            Color(uiColor: .systemBackground)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: -2)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

struct TabBarButton: View {
    let tab: TabItem
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .accentColor : .gray)
                
                Text(tab.title)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .accentColor : .gray)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
