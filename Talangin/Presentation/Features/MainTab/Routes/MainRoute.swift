//
//  MainRoute.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 12/01/26.
//


enum MainRoute: Hashable, Identifiable {
    case addExpense
    case createGroup
    case joinWithLink

    var id: Self { self }
}
