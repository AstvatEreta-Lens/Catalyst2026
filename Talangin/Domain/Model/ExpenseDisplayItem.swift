//
//  ExpenseDisplayItem.swift
//  OCR-Practice
//
//  Created by Ali Jazzy Rasyid on 20/01/26.
//

import Foundation
import SwiftUI

protocol ExpenseDisplayItem {
    var displayName: String { get }
    var displayInitials: String { get }
    var displayImageData: Data? { get }
}
