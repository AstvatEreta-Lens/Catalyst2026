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
        ScrollView {
            VStack(spacing: 0) {
                // MARK: - Profile Header
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
                .ignoresSafeArea(edges: .all)

                // MARK: - Premium Banner (only show for free users)
                if !viewModel.isPremium {
                    PremiumBannerView {
                        showPaywall = true
                    }
                }

                // MARK: - Payment Account
                ProfileSectionHeader(title: "PAYMENT ACCOUNT")
                paymentAccountSection
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, AppSpacing.lg)

                // MARK: - Groups and Friends
                ProfileSectionHeader(title: "PEOPLE AND GROUPS")
                groupsAndFriendsSection
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, AppSpacing.lg)

                // MARK: - Preferences
                ProfileSectionHeader(title: "PREFERENCES")
                preferencesSection
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, AppSpacing.lg)

                // MARK: - About
                ProfileSectionHeader(title: "ABOUT")
                aboutSection
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.bottom, AppSpacing.xxxl)
            }
        }
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
                currentPhone: viewModel.phoneNumber
            ) { name, email, phone in
                viewModel.updateProfile(name: name, email: email, phone: phone)
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

