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
        ZStack {
            // Background - Light green tint matching mockup
            Color(red: 0.9, green: 0.98, blue: 0.9)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Text("Home")
                            .font(.system(size: 34, weight: .bold))
                        
                        Spacer()
                        
                        // Debug indicator
                        Button {
                            let manualFetch = (try? modelContext.fetch(FetchDescriptor<GroupEntity>())) ?? []
                            print("🔍 Manual Fetch: Found \(manualFetch.count) groups")
                            for (index, group) in manualFetch.enumerated() {
                                print("  [\(index)] Group: \(group.name ?? ""), ID: \(String(describing: group.id))")
                            }
                        } label: {
                            Text("(\(groups.count))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 20)
                    
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
                .font(.title2.bold())
            
            Text("Create an expense to get started")
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    HomeView()
}

#Preview {
    // TES ACCESSIBILITY: SAMA AJA, bedanya adalah dengan penggunaan FontTokens, nantinya kita kalau mau di custom, jadinya lebih mudah
    VStack {
        Text("Ukuran Normal")
            .font(.body)
        
        Text("Ukuran Besar (Simulasi)")
            .font(.Body)
    }
    // Modifier ini mensimulasikan user yang menyalakan setting accessibility
    .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
}
