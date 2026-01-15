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
    static var Title1: Font {
        .title.weight(FontTokens.bold) // .title di SwiftUI setara Title1
    }
    
    /// Mapping: Title 2 (Default: 22pt)
    static var Title2: Font {
        .title2.weight(FontTokens.bold)
    }
    
    /// Mapping: Title 3 (Default: 20pt)
    static var Title3: Font {
        .title3.weight(FontTokens.semiBold)
    }
    
    // MARK: - BODY
    
    /// Mapping: Headline (Default: 17pt)
    static var Headline: Font {
        .headline.weight(FontTokens.semiBold)
    }
    
    /// Mapping: Body (Default: 17pt)
    static var Body: Font {
        .body.weight(FontTokens.regular)
    }
    
    /// Mapping: Callout (Default: 16pt)
    static var Callout: Font {
        .callout.weight(FontTokens.regular)
    }
    
    /// Mapping: Subheadline (Default: 15pt)
    static var Subheadline: Font {
        .subheadline.weight(FontTokens.regular)
    }
    
    // MARK: - CAPTIONS
    
    /// Mapping: Footnote (Default: 13pt)
    static var Footnote: Font {
        .footnote.weight(FontTokens.regular)
    }
    
    /// Mapping: Caption 1 (Default: 12pt)
    static var Caption: Font {
        .caption.weight(FontTokens.medium)
    }
    
    /// Mapping: Caption 2 (Default: 11pt)
    static var Caption2: Font {
        .caption2.weight(FontTokens.medium)
    }
    
    
    /*
     MARK: - FUTURE REFERENCE: CUSTOM FONT IMPLEMENTATION
     Gunakan pattern di bawah ini jika nanti Desainer ingin mengganti SF Pro
     dengan Custom Font (misal: Poppins/Inter) agar Dynamic Type tetap jalan.
     
     SEBELUMNYA:
     
     static var appBody: Font {
         .body.weight(FontTokens.regular)
     }
     
     DIUBAH JADI:
     
     static var appBody: Font {
         // Param 'relativeTo' adalah kunci agar font custom tetap bisa membesar otomatis!
         // Pastikan 'FontTokens.familyName' sudah didefinisikan di Font.swift
         return .custom(FontTokens.familyName, size: FontTokens.Body.size, relativeTo: .body)
     }

     static var appTitle1: Font {
         // Mapping ke relativeTo .title (agar scaling-nya setara Title 1)
         return .custom(FontTokens.familyName, size: FontTokens.Title1.size, relativeTo: .title)
     }
     
    */
    
}
