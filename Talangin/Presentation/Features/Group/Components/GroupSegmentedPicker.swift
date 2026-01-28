//
//  GroupSegmentedPicker.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 25/01/26.
//

import SwiftUI

struct GroupSegmentedPicker: View {
    @Binding var selectedTab: Int
    let tabs: [String]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                tabItem(title: tabs[index], index: index)
            }
        }
        .background(Color(red: 0.9, green: 0.9, blue: 0.92))
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .padding(.horizontal, 4)
    }

    
    private func tabItem(title: String, index: Int) -> some View {
        Button {
            selectedTab = index
        } label: {
            Text(title)
                .font(.subheadline)
                .fontWeight(selectedTab == index ? .semibold : .regular)
                .foregroundColor(selectedTab == index ? .black : .secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    selectedTab == index ? Color.white : Color.clear
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(2)
        }
    }
}

