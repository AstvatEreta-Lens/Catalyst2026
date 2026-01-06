//
//  ValidationHelper.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 06/01/26.
//


import Foundation

struct ValidationHelper {

    static func isValidEmail(_ email: String) -> Bool {
        let regex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", regex)
            .evaluate(with: email)
    }

    static func isValidPhone(_ phone: String) -> Bool {
        phone.count >= 10 && phone.allSatisfy(\.isNumber)
    }

    static func isNotEmpty(_ text: String) -> Bool {
        !text.trimmingCharacters(in: .whitespaces).isEmpty
    }
}