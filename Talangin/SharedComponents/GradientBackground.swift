//
//  GradientBackground.swift
//  Talangin
//
//  Created by Rifqi Rahman on 20/01/26.
//
import SwiftUI

// MARK: - Gradient Background
var gradientBackground: some View {
    
    ZStack {
        Rectangle()
            .foregroundColor(.clear)
            .background(
                LinearGradient(
                    stops: [
                        Gradient.Stop(color: Color(red: 0.17, green: 0.28, blue: 0.7), location: 0.00),
                        Gradient.Stop(color: Color(red: 0.12, green: 0.54, blue: 0.48), location: 0.82),
                        Gradient.Stop(color: Color(red: 0.09, green: 0.71, blue: 0.28), location: 1.00),
                    ],
                    startPoint: UnitPoint(x: 0, y: 1),
                    endPoint: UnitPoint(x: 1.2, y: 1.05)
                )
            )
        
        Rectangle()
            .foregroundColor(.clear)
            .background(
                LinearGradient(
                    stops: [
                        Gradient.Stop(color: Color(red: 0.02, green: 0.03, blue: 0.06), location: 0.00),
                        Gradient.Stop(color: Color(red: 0.11, green: 0.2, blue: 0.46).opacity(0), location: 1.00),
                    ],
                    startPoint: UnitPoint(x: 0.5, y: 1),
                    endPoint: UnitPoint(x: 0.5, y: 0)
                )
            )
    }
}
