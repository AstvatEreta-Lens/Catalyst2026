//
//  AuthGateView.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 06/01/26.
//


import SwiftUI
import SwiftData

struct AuthGateView: View {
    @EnvironmentObject private var authState: AppAuthState

    var body: some View {
        if authState.isAuthenticated {
            MainTabView()
        } else {
            SignInView() 
        }
    }
}

#Preview {
    AuthGateView()
        .environmentObject(AppAuthState())
}
