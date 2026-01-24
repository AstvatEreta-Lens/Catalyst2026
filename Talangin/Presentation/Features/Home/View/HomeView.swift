//
//  HomeView.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 06/01/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var groups: [GroupEntity]
    @State private var viewModel: HomeViewModel?
    
    // Using the same static ID as AddNewExpenseView for consistency in PoC
    private let currentUserID = UUID(uuidString: "00000000-0000-0000-0000-000000000001") ?? UUID()
    
    var body: some View {
        ZStack (alignment: .top){
            
            // Background - Light green tint matching mockup
            Color(red: 0.9, green: 0.98, blue: 0.9)
                .ignoresSafeArea()
            headerView
                .ignoresSafeArea()
            
            VStack {
                summaryCardView
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 20) {
                        
                        if groups.isEmpty {
                            emptyStateView
                                .frame(maxWidth: .infinity, minHeight: 400)
                        } else {
                            VStack(spacing: 16) {
                                ForEach(groups) { group in
                                    NavigationLink {
                                        GroupPageView(
                                            group: group,
                                            currentUserID: currentUserID
                                        )
                                    } label: {
                                        GroupCardView(
                                            group: group,
                                            currentUserID: currentUserID
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        
                        if let viewModel = viewModel, let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .padding()
                        }
                    }
                    .padding()
                }
                
            }
            .padding(.top, 130)
            .padding(.horizontal)
            .padding(.bottom, 30)
            
        }
        .onAppear {
            print("🏠 HomeView onAppear - Found \(groups.count) groups")
            if viewModel == nil {
                viewModel = HomeViewModel(modelContext: modelContext)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("No Groups Yet")
                .font(.Title2)
            
            Text("Create an expense to get started")
                .foregroundStyle(.secondary)
        }
        .padding()
    }
    
    
    private var headerView: some View {
        LinearGradient(
            stops: [
                Gradient.Stop(color: Color(red: 0.17, green: 0.28, blue: 0.7), location: 0.00),
                Gradient.Stop(color: Color(red: 0.12, green: 0.54, blue: 0.48), location: 0.82),
                Gradient.Stop(color: Color(red: 0.09, green: 0.71, blue: 0.28), location: 1.00),
            ],
            startPoint: UnitPoint(x: 0.02, y: 0),
            endPoint: UnitPoint(x: 1, y: 1.04)
        )
        .frame(width: .infinity, height: 282)
        .overlay(
            HStack {
                Text("Home")
                    .font(.appLargeTitle)
                Spacer()
                
                // Debug indicator
                Button {
                    let manualFetch = (try? modelContext.fetch(FetchDescriptor<GroupEntity>())) ?? []
                    print(" Manual Fetch: Found \(manualFetch.count) groups")
                    for (index, group) in manualFetch.enumerated() {
                        print("  [\(index)] Group: \(group.name ?? ""), ID: \(String(describing: group.id))")
                    }
                } label: {
                    Text("(\(groups.count))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
                .padding(.horizontal,16)
        )
        
        
    }
    private var summaryCardView: some View {
        VStack(spacing: 0){
            VStack{
                Color.white
            }
            

        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        
    }
}

#Preview {
    HomeView()
}
