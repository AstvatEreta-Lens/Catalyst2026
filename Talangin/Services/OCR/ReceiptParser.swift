//
//  ReceiptParser.swift
//  Talangin
//
//  Created by Ali Jazzy Rasyid on 18/01/26.
//

import Foundation

final class ReceiptParserService {
    
    static func parse(from rawText: String) -> [ExpenseItem] {
        print("⚙️ Memproses teks mentah...")
        
        let lines = rawText
            .split(separator: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        var itemNames: [String] = []
        var prices: [Int] = []
        
        for line in lines {
            
            if containsPrice(line) {
                if let price = extractPrice(from: line) {
                    prices.append(price)
                }
                continue
            }

            if containsWeirdSymbol(line) {
                continue
            }

            if isItemName(line) {
                let cleanedName = cleanItemName(line)
                if !cleanedName.isEmpty && cleanedName.count > 1 {
                    itemNames.append(cleanedName)
                }
            }
        }

        print("📊 Hasil Sementara: \(itemNames.count) Nama, \(prices.count) Harga")

        let count = min(itemNames.count, prices.count)
        
        let items = (0..<count).map { index in
            _ = 1
            let totalPrice = Double(prices[index])
            
            return ExpenseItem(
                name: itemNames[index],
                price: totalPrice
            )
        }
        
        return items
    }
    
    // MARK: - Helper Functions
    
    private static func containsWeirdSymbol(_ text: String) -> Bool {
        // HAPUS "x", "*", "/" dari sini agar tidak membuang baris penting
        let symbols = ["@", "#", "\\"]
        return symbols.contains { text.contains($0) }
    }
    
    private static func containsPrice(_ text: String) -> Bool {
        // Regex diperbaiki untuk menangkap Rp, dan format angka ribuan
        // Support: "15.000", "Rp 15000", "15,000", "x1 2.000"
        let pattern = #"(?:Rp\s?|x\s?\d+\s?)?(\d{1,3}[.,]\d{3})"#
        return text.range(of: pattern, options: .regularExpression) != nil
    }
    
    private static func extractPrice(from text: String) -> Int? {
        // Cari pola angka yang terlihat seperti uang
        let pattern = #"(\d{1,3}(?:[.,]\d{3})+)|\d{4,}"#
        
        guard let range = text.range(of: pattern, options: .regularExpression) else {
            return nil
        }
        
        let rawNumber = text[range]
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: "")
        
        return Int(rawNumber)
    }
    
    private static func isItemName(_ text: String) -> Bool {
        // Harus ada huruf A-Z, minimal 2 karakter untuk menghindari noise
        let letterPattern = "[A-Za-z]{2,}"
        return text.range(of: letterPattern, options: .regularExpression) != nil
    }
    
    private static func cleanItemName(_ text: String) -> String {
        
        var cleaned = text

        if let range = cleaned.range(of: "^[\\d\\W]+\\s", options: .regularExpression) {
            cleaned.removeSubrange(range)
        }

        let junkWords = ["item", "qty", "products", "shoppingbag", "total"]
        for junk in junkWords {
            if cleaned.lowercased().contains(junk) {
            }
        }
        
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
