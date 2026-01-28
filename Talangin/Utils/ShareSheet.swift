//
//  ShareSheet.swift
//  Talangin
//

import SwiftUI
import UIKit
import LinkPresentation

/// A reliable way to present UIActivityViewController in SwiftUI without sheet-nesting bugs.
struct ShareSheetPresenter: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var items: [Any]

    func makeUIViewController(context: Context) -> UIViewController {
        return UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented {
            if uiViewController.presentedViewController == nil {
                // Wrap items if they are URLs to provide better metadata
                let processedItems = items.map { item -> Any in
                    if let url = item as? URL {
                        return PDFActivityItemSource(fileURL: url)
                    }
                    return item
                }
                
                let activityController = UIActivityViewController(activityItems: processedItems, applicationActivities: nil)
                
                activityController.completionWithItemsHandler = { (_, _, _, _) in
                    isPresented = false
                }
                
                if let popover = activityController.popoverPresentationController {
                    popover.sourceView = uiViewController.view
                    popover.sourceRect = CGRect(x: uiViewController.view.bounds.midX, y: uiViewController.view.bounds.midY, width: 0, height: 0)
                    popover.permittedArrowDirections = []
                }
                
                DispatchQueue.main.async {
                    uiViewController.present(activityController, animated: true)
                }
            }
        }
    }
}

/// Helper class to explicitly tell iOS that this is a PDF file, fixing Code=-10814 errors.
class PDFActivityItemSource: NSObject, UIActivityItemSource {
    let fileURL: URL
    
    init(fileURL: URL) {
        self.fileURL = fileURL
        super.init()
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return fileURL
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return fileURL
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return fileURL.lastPathComponent
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, dataTypeIdentifierForActivityType activityType: UIActivity.ActivityType?) -> String {
        return "com.adobe.pdf"
    }
    
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = fileURL.lastPathComponent
        metadata.originalURL = fileURL
        metadata.url = fileURL
        return metadata
    }
}
