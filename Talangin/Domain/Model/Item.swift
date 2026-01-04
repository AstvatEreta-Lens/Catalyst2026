//
//  Item.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 01/01/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
