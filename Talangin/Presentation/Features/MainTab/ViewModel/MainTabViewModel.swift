//
//  MainTabViewModel.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 06/01/26.
//

import SwiftUI
import Combine

class MainTabViewModel: ObservableObject {
    @Published var selectedTab: TabDestination = .home
    @Published var tabs: [TabItem] = [
        TabItem(title: "Home", icon: AppIcons.Navigation.home, destination: .home),
        TabItem(title: "Friends", icon: AppIcons.Navigation.friend, destination: .friends),
        TabItem(title: "Profile", icon: AppIcons.Navigation.profile, destination: .profile)
    ]
    
    // Customization logic can be added here
    func changeTab(to destination: TabDestination) {
        selectedTab = destination
    }
}
