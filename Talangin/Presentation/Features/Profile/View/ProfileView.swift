//
//  ProfileView.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 06/01/26.
//
//  Profile screen using native SwiftUI List component following Apple HIG.
//  Uses native Section headers and List rows for consistent iOS experience.
//
//  BACKEND DEVELOPER NOTES:
//  -------------------------
//  This view displays user profile data from ProfileViewModel.
//  Data flows:
//  1. User info loaded from UserEntity via repository
//  2. Payment methods from PaymentMethodEntity relationship
//  3. Preferences stored in UserDefaults (theme, notifications, language)
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
            List {
                // MARK: - Profile Header Section
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
                        Text(viewModel.paymentMethods.first?.providerName ?? "Add Payment")
                    }
                } header: {
                    Text("PAYMENT ACCOUNT")
                }

                // MARK: - People and Groups
                Section {
                    NavigationLink {
                        ContactsView()
                    } label: {
                        Text("Your Friends and Groups")
                    }
                } header: {
                    Text("PEOPLE AND GROUPS")
                }

                // MARK: - Preferences
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

                // MARK: - About
                Section {
                    // Report problems - external link
                    Button {
                        // BACKEND NOTE: Open report URL
                        if let url = URL(string: "https://talangin.app/support") {
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
                    
                    // Privacy policy - external link
                    Button {
                        // BACKEND NOTE: Open privacy policy URL
                        if let url = URL(string: "https://talangin.app/privacy") {
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
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
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
            .fullScreenCover(isPresented: $showEditProfile) {
                EditProfileView(
                    currentName: viewModel.fullName,
                    currentEmail: viewModel.email,
                    currentPhone: viewModel.phoneNumber,
                    currentPhotoData: viewModel.profilePhotoData,
                    accountBadge: viewModel.isPremium ? "Premium" : "Free Account"
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
}

#Preview {
    ProfileView()
        .environmentObject(AppAuthState())
}
