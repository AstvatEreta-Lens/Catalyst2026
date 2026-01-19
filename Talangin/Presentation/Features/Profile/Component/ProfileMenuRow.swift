//
//  ProfileMenuRow.swift
//  Talangin
//
//  Created by Rifqi Rahman on 15/01/26.
//
//  Reusable menu row component for profile screen with various configurations.
//

import SwiftUI

struct ProfileMenuRow: View {
    enum RowType {
        case navigation
        case button
        case menu(selectedValue: Binding<String>, options: [String])
        case toggle(isOn: Binding<Bool>)
        case textOnly(value: String)
    }

    let title: String
    let type: RowType
    let action: (() -> Void)?

    init(
        title: String,
        type: RowType,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.type = type
        self.action = action
    }

    var body: some View {
        Group {
            switch type {
            case .navigation:
                navigationRow
            case .button:
                buttonRow
            case let .menu(selectedValue, options):
                menuRow(selectedValue: selectedValue, options: options)
            case let .toggle(isOn):
                toggleRow(isOn: isOn)
            case let .textOnly(value):
                textOnlyRow(value: value)
            }
        }
    }

    // MARK: - Navigation Row
    private var navigationRow: some View {
        HStack {
            Text(title)
                .foregroundColor(.primary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.md)
        .background(Color(.systemBackground))
    }

    // MARK: - Button Row (External Link)
    private var buttonRow: some View {
        Button {
            action?()
        } label: {
            HStack {
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)
            .background(Color(.systemBackground))
        }
    }

    // MARK: - Menu Row (Dropdown)
    private func menuRow(selectedValue: Binding<String>, options: [String]) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.primary)
            Spacer()
            Menu {
                ForEach(options, id: \.self) { option in
                    Button(option) {
                        selectedValue.wrappedValue = option
                    }
                }
            } label: {
                HStack(spacing: AppSpacing.xxs) {
                    Text(selectedValue.wrappedValue)
                        .foregroundColor(.secondary)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.sm)
        .background(Color(.systemBackground))
    }

    // MARK: - Toggle Row
    private func toggleRow(isOn: Binding<Bool>) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.primary)
            Spacer()
            Toggle("", isOn: isOn)
                .tint(AppColors.toggleTint)
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.sm)
        .background(Color(.systemBackground))
    }

    // MARK: - Text Only Row
    private func textOnlyRow(value: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.primary)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.md)
        .background(Color(.systemBackground))
    }
}

#Preview {
    VStack(spacing: 0) {
        ProfileMenuRow(
            title: "Payment Account",
            type: .navigation
        )
        
        Divider()
            .padding(.leading, 20)
        
        ProfileMenuRow(
            title: "Report problems",
            type: .button,
            action: {
                print("Report tapped")
            }
        )
        
        Divider()
            .padding(.leading, 20)
        
        ProfileMenuRow(
            title: "Theme",
            type: .menu(
                selectedValue: .constant("System (default)"),
                options: ["System (default)", "Light", "Dark"]
            )
        )
        
        Divider()
            .padding(.leading, 20)
        
        ProfileMenuRow(
            title: "Notifications",
            type: .toggle(isOn: .constant(true))
        )
        
        Divider()
            .padding(.leading, 20)
        
        ProfileMenuRow(
            title: "Version",
            type: .textOnly(value: "1.00")
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
