//
//  ReceiptParser.swift
//  Talangin
//
//  Created by Ali Jazzy Rasyid on 18/01/26.
//

import Foundation

final class ReceiptParserService {
    
    static func parse(from rawText: String) -> [ExpenseItem] {
        
        let lines = rawText
            .split(separator: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        var _: [ExpenseItem] = []
        var itemNames: [String] = []
        var prices: [Int] = []
        var quantities: [Int] = []
        
        for line in lines {

            if containsWeirdSymbol(line) {
                continue
            }
            
            let quantity = extractQuantity(from: line)
            if quantity > 0 {
                quantities.append(quantity)
                continue
            }

            if containsPrice(line) {
                if let price = extractPrice(from: line) {
                    prices.append(price)
                }
                continue
            }

            if isItemName(line) {
                itemNames.append(cleanItemName(line))
            }
            
        }

        let count = min(itemNames.count, prices.count)
        
        let items = (0..<count).map { index in
            let quantity = index < quantities.count ? quantities[index] : 1
            let totalPrice = Double(prices[index]) * Double(quantity)
            return ExpenseItem(
                name: itemNames[index],
                price: totalPrice
            )
        }
        
        return items
    }
    
    // MARK: - Helpers
    
    private static func extractQuantity(from text: String) -> Int {
        // Case 1: hanya satu angka
        let allNumbers = extractRawNumbers(from: text)
        if allNumbers.count == 1 {
            return allNumbers[0]
        }
        
        // Case 2: angka + simbol (1x, x1, 1@, #1, dll)
        let symbolPattern = "(\\d+\\s*[x@#]|[x@#]\\s*\\d+)"
        if let match = text.range(of: symbolPattern, options: .regularExpression) {
            let numberPattern = "\\d+"
            let matchedText = String(text[match])
            
            guard let numberRange = matchedText.range(
                of: numberPattern,
                options: .regularExpression
            ) else { return 0 }
            
            return Int(matchedText[numberRange]) ?? 0
        }
        
        return 0
    }
    
    private static func extractRawNumbers(from text: String) -> [Int] {
        let pattern = "\\d+"
        
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return []
        }
        
        let range = NSRange(location: 0, length: text.utf16.count)
        
        return regex.matches(in: text, range: range).compactMap {
            guard let range = Range($0.range, in: text) else { return nil }
            return Int(text[range])
        }
    }
    
    private static func containsWeirdSymbol(_ text: String) -> Bool {
        let symbols = ["@", "#", "x", "*", "/", "\\"]
        return symbols.contains { text.contains($0) }
    }
    
    private static func containsPrice(_ text: String) -> Bool {
        let pattern = "\\d{1,3}([.,]\\d{3})+"
        return text.range(of: pattern, options: .regularExpression) != nil
    }
    
    private static func extractPrice(from text: String) -> Int? {
        let pattern = "(\\d{1,3}(?:[.,]\\d{3})+|\\d+)"
        guard let match = text.range(of: pattern, options: .regularExpression) else {
            return nil
        }
        
        let raw = text[match]
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: "")
        
        return Int(raw)
    }
    
    private static func isItemName(_ text: String) -> Bool {
        text.range(of: "[A-Za-z]", options: .regularExpression) != nil
    }
    
    private static func cleanItemName(_ text: String) -> String {
        text.replacingOccurrences(of: "\\d|[x@#.,]", with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespaces)
    }
}
