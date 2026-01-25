//
//  Icon.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 06/01/26.
//

import SwiftUI

enum AppIcons {

    // MARK: - Auth
    enum Auth {
        static let apple = "applelogo"
        static let google = "globe"
        static let email = "envelope"
        static let password = "lock"
    }

    // MARK: - Navigation
    enum Navigation {
        static let home = "house"
        static let friend = "person.2"
        static let activity = "list.bullet.rectangle"
        static let profile = "person.crop.circle"
        static let group = "person.3"
    }

    // MARK: - Expense
    enum Expense {
        static let add = "plus.circle.fill"
        static let receipt = "doc.text.viewfinder"
        static let food = "fork.knife"
        static let movie = "film.fill"
        static let transport = "car.fill"
    }

    // MARK: - Action
    enum Action {
        static let edit = "pencil"
        static let delete = "trash.fill"
        static let share = "square.and.arrow.up"
        static let check = "checkmark.circle.fill"
        static let close = "xmark.circle.fill"
    }
    
    // MARK: - Custom Icon PNG/SVG dari designer (aset icon taro dulu di Assets)
    enum Custom {
        
    }
}
