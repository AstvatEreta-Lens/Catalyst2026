//
//  MainTabView.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 06/01/26.
//

import SwiftUI
import SwiftData


struct MainTabView: View {
    @StateObject private var viewModel = MainTabViewModel()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            ForEach(viewModel.tabs) { tab in
                destinationView(for: tab.destination)
                    .tabItem {
                        Label(tab.title, systemImage: tab.icon)
                    }
                    .tag(tab.destination)
            }
        }
    }

    @ViewBuilder
    private func destinationView(for destination: TabDestination) -> some View {
        switch destination {
        case .home:
            HomeView()

        case .friends:
            FriendView()

        case .profile:
            ProfileView()
        }
    }
}

#Preview("English") {
    MainTabView()
        .environment(\.locale, .init(identifier: "en"))
}

#Preview("Indonesia") {
    MainTabView()
        .environment(\.locale, .init(identifier: "id"))
}
