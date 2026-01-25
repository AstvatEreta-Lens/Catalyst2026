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
        NavigationStack {
            ZStack(alignment: .bottom) {
                
                // Content
                Group {
                    switch viewModel.selectedTab {
                    case .home:
                        HomeView()
                    case .profile:
                        ProfileView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Custom TabBar
                CustomTabBar(
                    selectedTab: $viewModel.selectedTab,
                    tabs: viewModel.tabs,
                    onAddTap: viewModel.handleAddButtonTap
                )
            }
            .ignoresSafeArea(.keyboard)
            .sheet(isPresented: $viewModel.showAddSheet) {
                AddActionSheet(
                    onAddExpenses: viewModel.goToAddExpense,
                    onCreateGroup: viewModel.goToCreateGroup,
                    onJoinWithLink: viewModel.goToJoinWithLink
                )
            }
            .navigationDestination(item: $viewModel.route) { route in
                destinationView(for: route)
            }
        }
    }

    @ViewBuilder
    private func destinationView(for route: MainRoute) -> some View {
        switch route {
        case .addExpense:
            AddNewExpenseView()
                .onDisappear { viewModel.clearRoute() }

        case .createGroup:
            CreateGroupView()
                .onDisappear { viewModel.clearRoute() }

        case .joinWithLink:
            JoinWithLinkView()
                .onDisappear { viewModel.clearRoute() }
        }
    }
}


#Preview {
    MainTabView()
        .environment(\.locale, .init(identifier: "id"))
}
