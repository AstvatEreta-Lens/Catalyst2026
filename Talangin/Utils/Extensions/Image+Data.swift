//
//  Image+Data.swift
//  Talangin
//
//  Created by Rifqi Rahman on 27/01/26.
//
//  SwiftUI Image extension for converting Data to Image.
//  Provides a cleaner API than direct UIImage conversion.
//

import SwiftUI
// NOTE: UIImage is required as a bridge between Data and SwiftUI Image
// This is the standard way to convert Data to Image in SwiftUI
import UIKit

extension Image {
    /// Creates a SwiftUI Image from image data (Data).
    /// This is a convenience wrapper around UIImage conversion.
    /// NOTE: UIImage is still required as a bridge, but this provides a cleaner API.
    init?(data: Data) {
        // UIImage is required as a bridge between Data and SwiftUI Image
        // This is the standard way to convert Data to Image in SwiftUI
        guard let uiImage = UIImage(data: data) else {
            return nil
        }
        self.init(uiImage: uiImage)
    }
}

extension Data {
    /// Creates a SwiftUI Image from this data.
    /// Returns nil if the data cannot be converted to an image.
    func toImage() -> Image? {
        Image(data: self)
    }
}
