//
//  Date+Format.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 06/01/26.
//

import Foundation

extension Date {

    func formatted(
        _ format: String = "dd MMM yyyy",
        locale: Locale = .current
    ) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = locale
        return formatter.string(from: self)
    }

    static func nowFormatted(_ format: String) -> String {
        Date().formatted(format)
    }
}
