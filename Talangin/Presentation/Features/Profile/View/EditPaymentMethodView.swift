//
//  EditPaymentMethodView.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 07/01/26.
//

import SwiftUI

struct EditPaymentMethodView: View {
    @Bindable var method: PaymentMethodEntity

    var body: some View {
        Form {

            Section("Provider") {
                TextField(
                    "Provider Name",
                    text: Binding(
                        get: { method.providerName ?? "" },
                        set: { method.providerName = $0 }
                    )
                )
            }

            Section("Destination") {
                TextField(
                    "Account / Number",
                    text: Binding(
                        get: { method.destination ?? "" },
                        set: { method.destination = $0 }
                    )
                )
            }
        }
        .navigationTitle("Edit Payment")
    }
}
