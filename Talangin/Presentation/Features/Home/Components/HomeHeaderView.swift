//
//  HomeHeaderView.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 24/01/26.
//

import SwiftUI

struct HomeHeaderView: View {

    var body: some View {
        LinearGradient(
            stops: [
                Gradient.Stop(color: Color(red: 0.17, green: 0.28, blue: 0.7), location: 0.00),
                Gradient.Stop(color: Color(red: 0.12, green: 0.54, blue: 0.48), location: 0.82),
                Gradient.Stop(color: Color(red: 0.09, green: 0.71, blue: 0.28), location: 1.00),
            ],
            startPoint: UnitPoint(x: 0.02, y: 0),
            endPoint: UnitPoint(x: 1, y: 1.04)
        )
        .frame(height: 280)
        .overlay(alignment: .top) {
            HStack {
                Text("Talangin")
                    .font(Font.appLargeTitle)
                    .foregroundColor(.white)
  
                Spacer()
                Button(action: {}) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 20, weight: .bold, design: .default))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 100)
    
        }
    }
}

#Preview {
    HomeHeaderView()
}
