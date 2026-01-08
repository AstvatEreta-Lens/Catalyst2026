//
//  EditPaymentMethodView.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 07/01/26.
//


import SwiftUI
import SwiftData

struct EditPaymentMethodView: View {
    @Bindable var method: PaymentMethodEntity

    var body: some View {
        Form {
            Section("Provider") {
                TextField("Provider Name", text: $method.providerName)
            }

            Section("Destination") {
                TextField("Account / Number", text: $method.destination)
            }
        }
        .navigationTitle("Edit Payment")
    }
}