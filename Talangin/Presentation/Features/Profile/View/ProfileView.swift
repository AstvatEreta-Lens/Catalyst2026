//
//  ProfileView.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 06/01/26.
//
//  Profile screen view with modular components for header, premium banner, and menu sections.
//  Updated: Added edit profile sheet and paywall integration.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var authState: AppAuthState
    
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showLogoutConfirm = false
    @State private var showPaywall = false
    @State private var showEditProfile = false
    
    var body: some View {
        NavigationStack {
            
            List{
                // MARK: - Profile Header
                Section {
                    ProfileHeaderView(
                        profilePhotoData: viewModel.profilePhotoData,
                        fullName: viewModel.fullName,
                        email: viewModel.email,
                        accountBadge: viewModel.isPremium ? "Premium" : "Free Account",
                        onEditTapped: {
                            showEditProfile = true
                        },
                        onPhotoChanged: { data in
                            viewModel.updatePhoto(data)
                        }
                    )
                }
                
                
                
                // MARK: - Premium Banner (only show for free users)
                if !viewModel.isPremium {
                    Section {
                        PremiumBannerView {
                            showPaywall = true
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                    }
                }
                
                // MARK: - Payment Account
                Section {
                    NavigationLink {
                        if let user = viewModel.user {
                            PaymentMethodListView(methods: viewModel.paymentMethods, user: user)
                        } else {
                            PaymentMethodEmptyStateView()
                        }
                    } label: {
                        Text(viewModel.paymentMethods.first?.providerName ?? "Set payment account")
                        
                    }
                } header: {
                    Text("PAYMENT ACCOUNT")
                }
                
                Section {
                    NavigationLink {
                        ContactsView()
                    } label: {
                        Text("Your Friends and Groups")
                        
                    }
                } header: {
                    Text("PEOPLE AND GROUPS")
                }
                
                // MARK: - Groups and Friends
                Section {
                    // Theme Picker
                    Picker("Theme", selection: $viewModel.selectedTheme) {
                        ForEach(ProfileViewModel.themeOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    
                    // Notifications Toggle
                    Toggle("Notifications", isOn: $viewModel.notificationsEnabled)
                        .tint(AppColors.toggleTint)
                    
                    // Language Picker
                    Picker("Language", selection: $viewModel.selectedLanguage) {
                        ForEach(ProfileViewModel.languageOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                } header: {
                    Text("PREFERENCES")
                }
                
                Section {
                    // Report problems - external link
                    Button {
                        // BACKEND NOTE: Open report URL
                        if let url = URL(string: "https://github.com/rifqi-rahman/Talangin/discussions") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack {
                            Text("Report problems")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Terms of Service - external link
                    Button {
                        // BACKEND NOTE: Open report URL
                        if let url = URL(string: "https://rifqi-rahman.github.io/Talangin/terms.html") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack {
                            Text("Terms of Service")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Privacy policy - external link
                    Button {
                        // BACKEND NOTE: Open privacy policy URL
                        if let url = URL(string: "https://rifqi-rahman.github.io/Talangin/privacy.html") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack {
                            Text("Privacy policy")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Version - read only
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(ProfileViewModel.appVersion)
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("ABOUT")
                }
                
                Section {
                    Button(role: .destructive) {
                        showLogoutConfirm.toggle()
                    } label: {
                        Text("Log Out")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .font(Font.body.bold())
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .inset(by: 0.5)
                            .stroke(Color.red, lineWidth: 1)
                    )
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                
                // MARK: - Safe Area Spacing
                // Best practice: Add a transparent section to ensure content
                // is pushed above the custom TabBar
                Section {
                    Color.clear
                        .frame(height: 80)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
                
                
            }
            
            
            .listStyle(.insetGrouped)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
            .alert(
                "Log Out",
                isPresented: $showLogoutConfirm
            ) {
                Button("Log Out", role: .destructive) {
                    authState.logout()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to log out?")
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred")
            }
            .fullScreenCover(isPresented: $showPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileView(
                    currentName: viewModel.fullName,
                    currentEmail: viewModel.email,
                    currentPhone: viewModel.phoneNumber,
                    currentPhotoData: viewModel.profilePhotoData
                ) { name, email, phone, photoData in
                    viewModel.updateProfile(name: name, email: email, phone: phone)
                    if let photoData = photoData {
                        viewModel.updatePhoto(photoData)
                    }
                }
            }
            
        }
        
        .onAppear {
            viewModel.injectContext(modelContext)
        }
    }
    
    
    // MARK: - Payment Account Section
    private var paymentAccountSection: some View {
        NavigationLink {
            if let user = viewModel.user {
                PaymentMethodListView(methods: viewModel.paymentMethods, user: user)
            } else {
                PaymentMethodEmptyStateView()
            }
        } label: {
            ProfileMenuRow(
                title: viewModel.paymentMethods.first?.providerName ?? "Set payment account",
                type: .navigation
            )
        }
    }
    
    // MARK: - Groups and Friends Section
    private var groupsAndFriendsSection: some View {
        NavigationLink {
            ContactsView()
        } label: {
            ProfileMenuRow(
                title: "Your Friends and Groups",
                type: .navigation
            )
        }
    }
    
    // MARK: - Preferences Section
    private var preferencesSection: some View {
        VStack(spacing: 0) {
            // Theme
            ProfileMenuRow(
                title: "Theme",
                type: .menu(selectedValue: $viewModel.selectedTheme, options: ProfileViewModel.themeOptions)
            )
            
            Divider()
                .padding(.leading, AppSpacing.lg)
            
            // Notifications
            ProfileMenuRow(
                title: "Notifications",
                type: .toggle(isOn: $viewModel.notificationsEnabled)
            )
            
            Divider()
                .padding(.leading, AppSpacing.lg)
            
            // Language
            ProfileMenuRow(
                title: "Language",
                type: .menu(selectedValue: $viewModel.selectedLanguage, options: ProfileViewModel.languageOptions)
            )
        }
    }
    
    // MARK: - About Section
    private var aboutSection: some View {
        VStack(spacing: 0) {
            // Report problems
            ProfileMenuRow(
                title: "Report problems",
                type: .button,
                action: {
                    // Open report URL
                }
            )
            
            Divider()
                .padding(.leading, AppSpacing.lg)
            
            // Privacy policy
            ProfileMenuRow(
                title: "Privacy policy",
                type: .button,
                action: {
                    // Open privacy policy URL
                }
            )
            
            Divider()
                .padding(.leading, AppSpacing.lg)
            
            // Version
            ProfileMenuRow(
                title: "Version",
                type: .textOnly(value: ProfileViewModel.appVersion)
            )
        }
    }
}


#Preview {
    NavigationStack {
        ProfileView()
            .environmentObject(AppAuthState())
    }
}

