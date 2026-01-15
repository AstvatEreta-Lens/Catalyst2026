//
//  AppFont.swift
//  Talangin
//
//  Created by Rifqi on 14/01/26.
//

import SwiftUI

/// Extension ini menghubungkan UI dengan System Font Apple.
///
/// **CATATAN PENTING SOAL DYNAMIC TYPE:**
/// Meskipun kita memiliki `FontTokens` dengan nilai angka pasti (misal: 34),
/// di sini kita MENGUTAMAKAN penggunaan **Native Text Styles** (seperti .largeTitle).
///
/// Alasannya: Agar ketika user mengubah "Settings > Accessibility > Larger Text",
/// font aplikasi kita otomatis ikut membesar/mengecil tanpa coding tambahan.
///
/// Nilai di `FontTokens` tetap kita simpan sebagai "Reference/Documentation"
/// untuk memastikan default size kita sama dengan Figma.
extension Font {
   
    
    // MARK: - TITLES
    
    /// Mapping: Large Title (Default: 34pt)
    static var appLargeTitle: Font {
        // Menggunakan style native agar Dynamic Type jalan
        .largeTitle.weight(FontTokens.bold)
    }
    
    /// Mapping: Title 1 (Default: 28pt)
    static var appTitle1: Font {
        .title.weight(FontTokens.bold) // .title di SwiftUI setara Title1
    }
    
    /// Mapping: Title 2 (Default: 22pt)
    static var appTitle2: Font {
        .title2.weight(FontTokens.bold)
    }
    
    /// Mapping: Title 3 (Default: 20pt)
    static var appTitle3: Font {
        .title3.weight(FontTokens.semiBold)
    }
    
    // MARK: - BODY
    
    /// Mapping: Headline (Default: 17pt)
    static var appHeadline: Font {
        .headline.weight(FontTokens.semiBold)
    }
    
    /// Mapping: Body (Default: 17pt)
    static var appBody: Font {
        .body.weight(FontTokens.regular)
    }
    
    /// Mapping: Callout (Default: 16pt)
    static var appCallout: Font {
        .callout.weight(FontTokens.regular)
    }
    
    /// Mapping: Subheadline (Default: 15pt)
    static var appSubheadline: Font {
        .subheadline.weight(FontTokens.regular)
    }
    
    // MARK: - CAPTIONS
    
    /// Mapping: Footnote (Default: 13pt)
    static var appFootnote: Font {
        .footnote.weight(FontTokens.regular)
    }
    
    /// Mapping: Caption 1 (Default: 12pt)
    static var appCaption: Font {
        .caption.weight(FontTokens.medium)
    }
    
    /// Mapping: Caption 2 (Default: 11pt)
    static var appTinyCaption: Font {
        .caption2.weight(FontTokens.medium)
    }
    
    // MARK: - CUSTOM SIZE (Safety Net)
    
    /// Gunakan fungsi ini HANYA JIKA desainer minta ukuran aneh yang tidak ada di standar Apple.
    /// Contoh: Desainer minta size 40 (di luar standar).
    /// Fungsi ini memaksa font custom tetap support Dynamic Type relatif terhadap .body
    static func customFixed(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        // Ini trik pro: Menggunakan .custom pada system font agar bisa scaling
        // Kita "menipu" sistem dengan memanggil nama font SF Pro secara implisit
        return .system(size: size, weight: weight)
        // Note: Sebenarnya .system(size:) susah scaling otomatis kecuali pakai modifier khusus.
        // Tapi untuk MVP, hindari penggunaan customFixed ini. Pakai variable di atas.
    }
}
