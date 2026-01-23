//
//  PayNowView.swift
//  Talangin
//
//  Created by Ali Jazzy Rasyid on 20/01/26.
//

import SwiftUI

struct SettlementView: View {
    
    @State private var selectedSegment: SettlementSegment = .active
    @State private var isExpanded: Bool = false
    @State private var selectedFilter = "Need To Pay"
    @State private var paySheetIsPresented: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea(edges: .bottom)
                
                ScrollView {
                    VStack(spacing: 24) {
                        Picker("Picker", selection: $selectedSegment) {
                            ForEach(SettlementSegment.allCases, id: \.self) {
                                Text($0.rawValue)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.top, 16)
                        
                        Button(action: {paySheetIsPresented = true}){
                            SettlementRowView(isExpanded: $isExpanded, onTap: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    isExpanded.toggle()
                                }
                            })
                        }
                        .buttonStyle(PlainButtonStyle())
                        .sheet(isPresented: $paySheetIsPresented) {
                            PayNowView()
                        }
                        
                        Button(action: {paySheetIsPresented = true}){
                            SettlementRowView(isExpanded: $isExpanded, onTap: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    isExpanded.toggle()
                                }
                            })
                        }
                        .buttonStyle(PlainButtonStyle())
                        .sheet(isPresented: $paySheetIsPresented) {
                            PayNowView()
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .navigationTitle("My Settlement")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button{print("Need To Pay")} label: {
                            Label("Need to pay", systemImage: "arrow.up.right", )
                        }
                        Button{print("Will Receive")} label: {
                            Label("Will Receive", systemImage: "arrow.down.left", )
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(selectedFilter)
                                .font(.system(size: 14, weight: .medium))
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .foregroundStyle(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
    }
}

// Enum Anda
enum SettlementSegment: String, CaseIterable {
    case active = "Active"
    case done = "Done"
}

#Preview {
    SettlementView()
}
