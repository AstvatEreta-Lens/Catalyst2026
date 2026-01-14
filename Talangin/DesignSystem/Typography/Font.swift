//
//  Font.swift
//  Talangin
//
//  Created by Rifqi on 14/01/26.
//

import SwiftUI

/// FontTokens menyimpan nilai mentah (Raw Values) sesuai iOS 18 Design System.
/// Referensi: iOS 18 & iPadOS 18 Figma UI Kit.
///
enum FontTokens {
    
    // MARK: - Generic Weights
    static let regular: Font.Weight = .regular
    static let medium: Font.Weight = .medium
    static let semiBold: Font.Weight = .semibold
    static let bold: Font.Weight = .bold
    
    // MARK: - Typography Styles (Size & Line Height)
    
    struct LargeTitle {
        static let size: CGFloat = 34
        static let lineHeight: CGFloat = 41
    }
    
    struct Title1 {
        static let size: CGFloat = 28
        static let lineHeight: CGFloat = 34
    }
    
    struct Title2 {
        static let size: CGFloat = 22
        static let lineHeight: CGFloat = 28
    }
    
    struct Title3 {
        static let size: CGFloat = 20
        static let lineHeight: CGFloat = 25
    }
    
    struct Headline {
        static let size: CGFloat = 17
        static let lineHeight: CGFloat = 22
    }
    
    struct Body {
        static let size: CGFloat = 17
        static let lineHeight: CGFloat = 22
    }
    
    struct Callout {
        static let size: CGFloat = 16
        static let lineHeight: CGFloat = 21
    }
    
    struct Subheadline {
        static let size: CGFloat = 15
        static let lineHeight: CGFloat = 20
    }
    
    struct Footnote {
        static let size: CGFloat = 13
        static let lineHeight: CGFloat = 18
    }
    
    struct Caption1 {
        static let size: CGFloat = 12
        static let lineHeight: CGFloat = 16
    }
    
    struct Caption2 {
        static let size: CGFloat = 11
        static let lineHeight: CGFloat = 13
    }
}


// MARK: CATATAN PENGEMBANGAN (DEV NOTE)
/// Struct di bawah ini menyertakan properti `lineHeight` sesuai spesifikasi Figma.
/// Saat ini, implementasi UI utama di `AppFont` hanya menggunakan `size` karena SwiftUI
/// sudah menangani line spacing secara native (Dynamic Type) dengan sangat baik.
///
/// **Cara Implementasi Custom Line Height (Jika Diperlukan):**
/// Jika Desainer membutuhkan jarak antar baris yang presisi (Pixel Perfect), gunakan modifier `.lineSpacing()`:
/// ```swift
/// Text("Contoh")
///     .font(.appBody)
///     .lineSpacing(FontTokens.Body.lineHeight - FontTokens.Body.size)
/// ```
