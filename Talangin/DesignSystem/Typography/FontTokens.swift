//
//  FontTokens.swift
//  Talangin
//
//  Created by Rifqi on 14/01/26.
//

import SwiftUI

/// FontTokens menyimpan nilai mentah (Raw Values).
/// Jangan gunakan struct ini langsung di View, gunakan via AppFont (extension Font).
enum FontTokens {
    
    // MARK: - Font Weights
    // Kita gunakan tipe Font.Weight agar kompatibel dengan System Font Apple
    static let regular: Font.Weight = .regular
    static let medium: Font.Weight = .medium
    static let semiBold: Font.Weight = .semibold
    static let bold: Font.Weight = .bold

    // MARK: - Font Sizes
    static let xs: CGFloat = 12
    static let sm: CGFloat = 14
    static let md: CGFloat = 16
    static let lg: CGFloat = 18
    static let xl: CGFloat = 22
    static let xxl: CGFloat = 28
}
