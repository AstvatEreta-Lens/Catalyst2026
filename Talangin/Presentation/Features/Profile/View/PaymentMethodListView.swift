//
//  PaymentMethodListView.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 07/01/26.
//

import SwiftUI
import SwiftData

struct PaymentMethodListView: View {
    let methods: [PaymentMethodEntity]

    var body: some View {
        List {
            ForEach(methods) { method in
                NavigationLink {
                    EditPaymentMethodView(method: method)
                } label: {
                    VStack(alignment: .leading) {
                        Text(method.providerName)
                        Text(method.destination)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Payment Methods")
        .toolbar {
            Button {
                // add new
            } label: {
                Image(systemName: "plus")
            }
        }
    }
}
