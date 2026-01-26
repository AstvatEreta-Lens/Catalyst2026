//
//  CameraView.swift
//  Talangin
//
//  Created by Ali Jazzy Rasyid on 09/01/26.
//

import Foundation
import SwiftUI
import UIKit

struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage? // bind to the parent view's state
    @Environment(\.presentationMode) var presentationMode // Dismiss the view when done
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController() // Create the Camera picker
        picker.delegate = context.coordinator // Set the coordinatior as delegate
        picker.sourceType = .camera // set the source to the camera
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // No Updates Needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image // pass the selected image to the parent
            }
            parent.presentationMode.wrappedValue.dismiss() //dismiss the picker
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss() // dismiss on cancel
        }
    }
}
