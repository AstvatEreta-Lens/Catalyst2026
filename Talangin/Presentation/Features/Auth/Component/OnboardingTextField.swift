//
//  OnboardingTextField.swift
//  Talangin
//
//  Created by Rifqi Rahman on 19/01/26.
//
//  Custom text field component for onboarding and authentication screens.
//  Features clear button, password visibility toggle, and rounded design.
//
//  BACKEND DEVELOPER NOTES:
//  -------------------------
//  This is a UI component only. No backend integration needed.
//  Text binding is passed in from parent view for validation.
//

import SwiftUI

struct OnboardingTextField: View {
    
    // MARK: - Properties
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false
    var showClearButton: Bool = false
    var showVisibilityToggle: Bool = false
    @Binding var isPasswordVisible: Bool
    
    // MARK: - Init with visibility toggle
    init(
        placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default,
        isSecure: Bool = false,
        showClearButton: Bool = false,
        showVisibilityToggle: Bool = false,
        isPasswordVisible: Binding<Bool> = .constant(false)
    ) {
        self.placeholder = placeholder
        self._text = text
        self.keyboardType = keyboardType
        self.isSecure = isSecure
        self.showClearButton = showClearButton
        self.showVisibilityToggle = showVisibilityToggle
        self._isPasswordVisible = isPasswordVisible
    }
    
    var body: some View {
        HStack {
            // Text Field
            if isSecure {
                SecureField(placeholder, text: $text)
                    .font(.Body)
            } else {
                TextField(placeholder, text: $text)
                    .font(.Body)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(keyboardType == .emailAddress ? .never : .words)
                    .autocorrectionDisabled()
            }
            
            Spacer()
            
            // Clear Button
            if showClearButton && !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.secondary)
                }
            }
            
            // Visibility Toggle (for password fields)
            if showVisibilityToggle {
                Button {
                    isPasswordVisible.toggle()
                } label: {
                    Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        OnboardingTextField(
            placeholder: "Email Address",
            text: .constant("test@example.com"),
            keyboardType: .emailAddress,
            showClearButton: true
        )
        
        OnboardingTextField(
            placeholder: "Password",
            text: .constant("password123"),
            isSecure: true,
            showVisibilityToggle: true,
            isPasswordVisible: .constant(false)
        )
        
        OnboardingTextField(
            placeholder: "Full Name",
            text: .constant(""),
            showClearButton: true
        )
    }
    .padding()
}
