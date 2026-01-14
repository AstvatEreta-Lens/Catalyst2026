//
//  Font.swift
//  Talangin
//
//  Created by Rifqi on 14/01/26.
//

import SwiftUI

/// Extension ini membuat pemanggilan font menjadi semantik dan konsisten.
/// Usage: Text("Judul").font(.appTitle)
extension Font {

    // MARK: - Heading
    
    /// Gunakan untuk Judul Halaman Utama (Size: 28, Bold)
    static var appTitle: Font {
        .system(size: FontTokens.xxl, weight: FontTokens.bold, design: .default)
    }
    
    /// Gunakan untuk Sub-judul atau Section Header (Size: 22, SemiBold)
    static var appSubtitle: Font {
        .system(size: FontTokens.xl, weight: FontTokens.semiBold, design: .default)
    }

    // MARK: - Body
    
    /// Gunakan untuk teks paragraf standar (Size: 16, Regular)
    static var appBody: Font {
        .system(size: FontTokens.md, weight: FontTokens.regular, design: .default)
    }
    
    /// Gunakan untuk teks paragraf yang butuh penekanan (Size: 16, Medium)
    static var appBodyMedium: Font {
        .system(size: FontTokens.md, weight: FontTokens.medium, design: .default)
    }

    // MARK: - Caption & Footnote
    
    /// Gunakan untuk label form atau keterangan tambahan (Size: 14, Regular)
    static var appCaption: Font {
        .system(size: FontTokens.sm, weight: FontTokens.regular, design: .default)
    }
    
    /// Gunakan untuk teks timestamp atau legal disclaimer (Size: 12, Regular)
    static var appFootnote: Font {
        .system(size: FontTokens.xs, weight: FontTokens.regular, design: .default)
    }
}
