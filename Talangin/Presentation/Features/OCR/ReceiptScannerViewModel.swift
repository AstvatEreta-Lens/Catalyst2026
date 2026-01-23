//
//  ReceiptScannerViewModel.swift
//  OCR-Practice
//
//  Created by Ali Jazzy Rasyid on 18/01/26.
//

import UIKit
import SwiftUI
import Combine

final class ReceiptScannerViewModel: ObservableObject {
    
    // MARK: - Output ke View
    @Published var isProcessing = false
    @Published var items: [ExpenseItem] = []
    @Published var error: ReceiptScanError?
    
    // MARK: - Public API
    func scan(image: UIImage) {
        reset()
        
        isProcessing = true
        
        ObjectDetectionService.shared.detect(image: image) { [weak self] detections in
            guard let self else { return }
            
            guard let daftarBarang = detections.first(where: {
                $0.label == "daftar_barang"
            }) else {
                self.fail(.regionNotFound)
                return
            }
            
            guard let cropped = image.crop(to: daftarBarang.boundingBox) else {
                self.fail(.cropFailed)
                return
            }
            
            OCRService.recognizeText(from: cropped) { [weak self] text in
                guard let self else { return }
                
                Task { @MainActor in
                    if text.isEmpty {
                        self.fail(.ocrFailed)
                        return
                    }

                    let parsedItems = ReceiptParserService.parse(from: text)
                    
                    self.items = parsedItems
                    self.isProcessing = false
                }
            }
        }
    }
    
    // MARK: - Helpers
    private func reset() {
        items = []
        error = nil
    }
    
    private func fail(_ error: ReceiptScanError) {
        self.error = error
        self.isProcessing = false
    }
}

enum ReceiptScanError: LocalizedError {
    case detectionFailed
    case regionNotFound
    case cropFailed
    case ocrFailed
    
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
        }
    }
}


