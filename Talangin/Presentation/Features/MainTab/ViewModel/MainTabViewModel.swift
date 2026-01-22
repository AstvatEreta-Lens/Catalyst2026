//
//  MainTabViewModel.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 06/01/26.
//

import SwiftUI
import Combine

@MainActor
final class MainTabViewModel: ObservableObject {

    // Tab
    @Published var selectedTab: TabDestination = .home

    // Sheet
    @Published var showAddSheet: Bool = false

    // Navigation
    @Published var route: MainRoute?

    let tabs: [TabItem] = [
        TabItem(title: "Home", icon: AppIcons.Navigation.home, destination: .home),
        TabItem(title: "Profile", icon: AppIcons.Navigation.profile, destination: .profile)
    ]

    // MARK: - Intents

    func handleAddButtonTap() {
        showAddSheet = true
    }

    func goToAddExpense() {
        showAddSheet = false
        route = .addExpense
    }

    func goToCreateGroup() {
        showAddSheet = false
        route = .createGroup
    }

    func goToJoinWithLink() {
        showAddSheet = false
        route = .joinWithLink
    }

    func clearRoute() {
        route = nil
    }
}
