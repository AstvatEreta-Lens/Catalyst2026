//
//  SummaryCardView.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 24/01/26.
//
//import SwiftUI
import SwiftUI

struct SummaryCardView: View {

    var body: some View {
        ZStack(alignment: .bottom) {

            // MARK: - Main Card
            VStack(spacing: 0) {
                summaryRow(
                    title: "YOU NEED TO PAY",
                    amount: 100_000,
                    isPositive: false
                )

                Divider()

                summaryRow(
                    title: "WAITING FOR PAYMENT",
                    amount: 100_000_000,
                    isPositive: true
                )
            }
            .padding(.bottom, 44) // ruang untuk button
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(0.08), radius: 10, y: 6)

            // MARK: - Bottom Button
            Button(action: {
                print("See details tapped")
            }) {
                HStack {
                    Text("See Details")
                        .font(Font.subheadline.bold())
                    Spacer()

                    Image(systemName: "arrow.right")
                }
                .foregroundColor(.white)
                .padding(.horizontal)
                .frame(height: 40)
                .background(
                    Color(red: 0.6, green: 0.79, blue: 0.3)
                )
            }
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 20,
                    style: .continuous
                )
            )
            .mask(
                VStack(spacing: 0) {
                    Rectangle()
                    RoundedRectangle(cornerRadius: 20)
                        .frame(height: 48)
                }
            )
        }
    }

    private func summaryRow(
        title: String,
        amount: Double,
        isPositive: Bool
    ) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)

                HStack {
                    Image(systemName: isPositive ? "arrow.down.left" : "arrow.up.right")
                        .foregroundColor(isPositive ? .green : .red)

                    Text(amount.formatted(.currency(code: "IDR")))
                        .font(.system(size: 22, weight: .bold))
                }
            }

            Spacer()

            Circle()
                .fill(Color(.systemGray5))
                .frame(width: 40, height: 40)
        }
        .padding()
    }
}

#Preview {
    SummaryCardView()
}
