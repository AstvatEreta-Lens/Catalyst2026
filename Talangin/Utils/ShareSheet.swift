//
//  ShareSheet.swift
//  Talangin
//

import SwiftUI
import UIKit

struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    var excludedActivityTypes: [UIActivity.ActivityType]? = nil
    var completionHandler: UIActivityViewController.CompletionWithItemsHandler? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        controller.excludedActivityTypes = excludedActivityTypes
        controller.completionWithItemsHandler = completionHandler
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
