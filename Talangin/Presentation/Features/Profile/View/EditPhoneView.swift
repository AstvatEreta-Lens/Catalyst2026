//
//  EditPhoneView.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 07/01/26.
//

import SwiftUI

struct EditPhoneView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var phone: String

    let onSave: (String?) -> Void

    init(phoneNumber: String?, onSave: @escaping (String?) -> Void) {
        _phone = State(initialValue: phoneNumber ?? "")
        self.onSave = onSave
    }

    var body: some View {
        Form {
            TextField("Phone Number", text: $phone)
                .keyboardType(.phonePad)
        }
        .navigationTitle("Phone Number")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    onSave(phone.isEmpty ? nil : phone)
                    dismiss()
                }
            }
        }
    }
}
