//
//  ProfileView.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 06/01/26.
//

import SwiftUI
import SwiftData

struct ProfileView: View {

    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var authState: AppAuthState

    @StateObject private var viewModel = ProfileViewModel()
    @State private var showLogoutConfirm = false

    var body: some View {
        NavigationStack {
            Form {
                // Profile Header
                Section {
                    ProfileHeaderView(
                        imageData: viewModel.profilePhotoData,
                        onEditPhoto: viewModel.updatePhoto
                    )
                }

                Section("Account") {
                    LabeledContent("User ID", value: viewModel.userId)
                    LabeledContent("Full Name", value: viewModel.fullName)
                    LabeledContent("Email", value: viewModel.email)
                }

                Section("Contact") {
                    NavigationLink {
                        EditPhoneView(
                            phoneNumber: viewModel.phoneNumber,
                            onSave: viewModel.updatePhone
                        )
                    } label: {
                        LabeledContent(
                            "Phone Number",
                            value: viewModel.phoneNumber ?? "Not set"
                        )
                    }
                }

                Section("Payment Methods") {
                    NavigationLink {
                        PaymentMethodListView(
                            methods: viewModel.paymentMethods
                        )
                    } label: {
                        Text("Manage Payment Methods")
                    }
                }

                Section {
                    LabeledContent(
                        "Joined",
                        value: viewModel.createdAtFormatted
                    )
                }

                Section {
                    Button(role: .destructive) {
                        showLogoutConfirm = true
                    } label: {
                        HStack {
                            Spacer()
                            Text("Log Out")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Profile")
        }
        .onAppear {
            viewModel.injectContext(modelContext)
        }
    }
}
