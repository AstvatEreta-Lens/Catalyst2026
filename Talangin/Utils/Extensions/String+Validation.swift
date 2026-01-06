//
//  String+Validation.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 06/01/26.
//

import Foundation

extension String {

    var isValidEmail: Bool {
        let regex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", regex)
            .evaluate(with: self)
    }

    var isNumeric: Bool {
        Double(self) != nil
    }

    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
