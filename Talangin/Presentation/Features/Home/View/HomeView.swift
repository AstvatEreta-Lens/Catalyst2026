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
            
            
            VStack {
                        // Panggil dari enum L10n yang kita buat
                        Text(L10n.Common.welcome)
                            .font(.appTitle) // Pakai font yang sudah kita buat sebelumnya
                        
                        Text(L10n.Common.save)
                            .font(.appBody)
                    }
                    .padding()
        }
    }
}

#Preview {
    HomeView()
}

#Preview {
    // TES ACCESSIBILITY
    VStack {
        Text("Ukuran Normal")
            .font(.body)
        
        Text("Ukuran Besar (Simulasi)")
            .font(.appBody)
    }
    // Modifier ini mensimulasikan user yang menyalakan setting accessibility
    .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
}
