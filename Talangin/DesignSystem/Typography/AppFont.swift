//
//  AppFont.swift
//  Talangin
//
//  Created by Rifqi on 14/01/26.
//

import SwiftUI

/// Extension ini menghubungkan FontTokens dengan UI Aplikasi.
/// Menggunakan pendekatan Hybrid:
/// 1. Menggunakan `.system()` agar mendukung Dynamic Type & Native Feel.
/// 2. Mengambil nilai `size` dari `FontTokens` agar terpusat (Single Source of Truth).
extension Font {
    
    // MARK: - TITLES (Display & Headers)
    
    /// Style: Large Title (34pt) - Bold
    /// Gunakan untuk judul halaman utama yang sangat besar.
    static var appLargeTitle: Font {
        .system(size: FontTokens.LargeTitle.size, weight: FontTokens.bold)
    }
    
    /// Style: Title 1 (28pt) - Bold
    /// Gunakan untuk judul level 1.
    static var appTitle1: Font {
        .system(size: FontTokens.Title1.size, weight: FontTokens.bold)
    }
    
    /// Style: Title 2 (22pt) - Bold
    /// Gunakan untuk section header atau judul level 2.
    static var appTitle2: Font {
        .system(size: FontTokens.Title2.size, weight: FontTokens.bold)
    }
    
    /// Style: Title 3 (20pt) - SemiBold
    /// Gunakan untuk judul level 3 atau sub-section.
    static var appTitle3: Font {
        .system(size: FontTokens.Title3.size, weight: FontTokens.semiBold)
    }
    
    // MARK: - BODY & CONTENT
    
    /// Style: Headline (17pt) - SemiBold
    /// Gunakan untuk teks paragraf yang butuh penekanan (Highlight).
    static var appHeadline: Font {
        .system(size: FontTokens.Headline.size, weight: FontTokens.semiBold)
    }
    
    /// Style: Body (17pt) - Regular
    /// Gunakan untuk teks utama (Default text).
    static var appBody: Font {
        .system(size: FontTokens.Body.size, weight: FontTokens.regular)
    }
    
    /// Style: Callout (16pt) - Regular
    /// Gunakan untuk kotak info atau highlight text terpisah.
    static var appCallout: Font {
        .system(size: FontTokens.Callout.size, weight: FontTokens.regular)
    }
    
    /// Style: Subheadline (15pt) - Regular
    /// Gunakan untuk subtitle di bawah headline.
    static var appSubheadline: Font {
        .system(size: FontTokens.Subheadline.size, weight: FontTokens.regular)
    }
    
    // MARK: - CAPTIONS & DETAILS
    
    /// Style: Footnote (13pt) - Regular
    /// Gunakan untuk catatan kaki atau helper text.
    static var appFootnote: Font {
        .system(size: FontTokens.Footnote.size, weight: FontTokens.regular)
    }
    
    /// Style: Caption 1 (12pt) - Medium
    /// Gunakan untuk label kecil pada form atau metadata.
    static var appCaption: Font {
        .system(size: FontTokens.Caption1.size, weight: FontTokens.medium)
    }
    
    /// Style: Caption 2 (11pt) - Medium
    /// Gunakan untuk timestamp atau indikator status yang sangat kecil.
    static var appTinyCaption: Font {
        .system(size: FontTokens.Caption2.size, weight: FontTokens.medium)
    }
}
