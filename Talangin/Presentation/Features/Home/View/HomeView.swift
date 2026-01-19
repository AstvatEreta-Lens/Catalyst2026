//
//  HomeView.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 06/01/26.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "house.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue.gradient)
                
                Text("Home Screen")
                    .font(.largeTitle.bold())
                
                Text("WELCOME TO TALANGIN!")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                
               
            }
            .navigationTitle("Home")
        }
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
