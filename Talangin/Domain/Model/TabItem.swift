//
//  TabItem.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 06/01/26.
//

import SwiftUI

enum TabDestination: Hashable {
    case home
    case friends
    case profile
}

struct TabItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let icon: String
    let destination: TabDestination
}
