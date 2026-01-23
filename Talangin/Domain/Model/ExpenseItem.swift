//
//  ExpenseItem.swift
//  OCR-Practice
//
//  Created by Ali Jazzy Rasyid on 14/01/26.
//

import Foundation

struct ExpenseItem: Identifiable{
    var id = UUID()
    var itemName: String
    var itemPrice: Double
    var itemQuantity: Int
}
