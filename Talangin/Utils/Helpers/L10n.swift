//
//  L10n.swift
//  Talangin
//
//  Created by Rifqi Rahman on 14/01/26.
//

import SwiftUI

/// Helper untuk mengelola teks aplikasi agar terpusat dan aman.
enum L10n {
    
    // Kita buat kategori "Common" untuk kata-kata umum
    enum Common {
        /// Default: "Welcome"
        static let welcome = LocalizedStringResource("common_welcome", defaultValue: "Welcome")
        
        /// Default: "Save"
        static let save = LocalizedStringResource("common_save", defaultValue: "Save")
    }
}
