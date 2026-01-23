//
//  InitialsAvatar.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 14/01/26.
//

import Foundation
import SwiftUI

// MARK: - Shared Components
struct InitialsAvatar: View {
    let initials: String
    var size: CGFloat = 32
    
    var body: some View {
        Text(initials)
            .font(.system(size: size * 0.4, weight: .bold))
            .frame(width: size, height: size)
            .background(Color.gray.opacity(0.3))
            .clipShape(Circle())
    }
}
