//
//  ReceiptScanError.swift
//  Talangin
//
//  Created by Ali Jazzy Rasyid on 27/01/26.
//

import Foundation

enum ReceiptScanError: LocalizedError {
    case detectionFailed
    case regionNotFound
    case cropFailed
    case ocrFailed
    case parsingFailed
    
    var errorDescription: String? {
        switch self {
        case .detectionFailed:
            return "Gagal mendeteksi struk"
        case .regionNotFound:
            return "Daftar barang tidak ditemukan"
        case .cropFailed:
            return "Gagal memotong gambar"
        case .ocrFailed:
            return "Gagal membaca teks"
        case .parsingFailed:
            return "Fitur OCR gagal membaca teks"
        }
    }
}
