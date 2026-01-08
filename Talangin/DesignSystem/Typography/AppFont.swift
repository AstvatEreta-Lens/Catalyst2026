//
//  Untitled.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 06/01/26.
//

import SwiftUI

enum AppFonts {

    // Heading
    static let title = Font.custom(FontTokens.bold, size: FontTokens.xxl)
    static let subtitle = Font.custom(FontTokens.semiBold, size: FontTokens.xl)

    // Body
    static let body = Font.custom(FontTokens.regular, size: FontTokens.md)
    static let bodyMedium = Font.custom(FontTokens.medium, size: FontTokens.md)

    // Caption
    static let caption = Font.custom(FontTokens.regular, size: FontTokens.sm)
    static let footnote = Font.custom(FontTokens.regular, size: FontTokens.xs)
    
    // Bisa ditambahkan sesuai kebutuhan
}
